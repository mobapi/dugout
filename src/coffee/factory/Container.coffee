app
.factory 'Container',
['$q', '$timeout', 'globalConfMgr',
($q, $timeout, globalConfMgr) ->

	class Container

		@docker: null

		@initDocker: (globalConf) ->
			throw new Error("Cannot initialize without configuration") if not globalConf
			Docker = require 'dockerode'
			Docker.prototype.getContainerByName = (name, cb) ->
				@listContainers
					all: true
				, (error, containers) =>
					if error
						return cb error
					matched = _.filter containers, (container) ->
						found = false
						for n in container.Names
							if n.indexOf(name) > -1
								found = true
								break
						return found
					if matched.length
						container = @getContainer matched[0].Id
					else
						container = null
					return cb null, container
			if globalConf.docker.connectionType == 'socket'
				@docker = new Docker
					socketPath: globalConf.docker.socket
			else if globalConf.docker.connectionType == 'tcpip'
				options =
					host: globalConf.docker.address
					port: globalConf.docker.port
				if globalConf.docker.secure
					fs = require 'fs'
					options.ca = fs.readFileSync "#{globalConf.docker.certPath}/ca.pem"
					options.cert = fs.readFileSync "#{globalConf.docker.certPath}/cert.pem"
					options.key = fs.readFileSync "#{globalConf.docker.certPath}/key.pem"
				@docker = new Docker options

		constructor: (@name, conf) ->
			angular.extend @, conf
			@runtime =
				globalConf: {}
				configurationValid: false
				infos:
					image: {}
					container: {}
				log:
					streamsHandlers:
						stdout: null
						stderr: null
					streams:
						stdout: ""
						stderr: ""
					addToLog: (log) ->
						@streams[log.stream] += log.data
					clearLog: ->
						@streams.stdout = ""
						@streams.stderr = ""

		checkConfiguration: ->
			@runtime.configurationValid = false
			if @variables
				for variableName, variable of @variables
					return @runtime.configurationValid if variable.mandatory and not variable.value
			@runtime.configurationValid = true
			return @runtime.configurationValid

		checkContainerStatus: ->
			q = $q.defer()
			@getImageInfos(@image).then (infos) =>
				@runtime.infos.image = infos
				@getContainerInfos(@name).then (infos) =>
					@runtime.infos.container = infos
					q.resolve()
				, (error) =>
					delete @runtime.infos.container
					q.reject error
			, (error) =>
				q.reject error
			return q.promise

		substitute: (params, vars) ->
			out = {}
			for kp, p of params
				if typeof p == 'object'
					if p.length
						out[kp] = []
						for a, k in p
							out[kp][k] = @substitute params[kp][k], vars
					else
						out[kp] = @substitute params[kp], vars
				else
					out[kp] = _.template(p)(vars)
			return out

		_start: ->
			d = $q.defer()
			parameters = @runtime.parameters
			opts =
				name: @name
				Image: @image
				# Tty: true
				Hostname: @name
				HostConfig: {}
			if parameters.hostname
				opts.Hostname = parameters.hostname
			if parameters.cmd
				opts.Cmd = []
				opts.Cmd.push "sh"
				opts.Cmd.push "-c"
				opts.Cmd.push "#{parameters.cmd}"
			if parameters.mounts
				# opts.Volumes = {}
				# for k, v of parameters.mounts
				# 	opts.Volumes[k] = {}
				opts.HostConfig.Binds = []
				for k, v of parameters.mounts
					opts.HostConfig.Binds.push "#{v}:#{k}"
			if parameters.links
				opts.HostConfig.Links = []
				for k, l of parameters.links
					opts.HostConfig.Links.push "#{l}:#{k}"
			if parameters.ports
				opts.ExposedPorts = {}
				for k, p of parameters.ports
					opts.ExposedPorts[k] = {}
				opts.HostConfig.PortBindings = {}
				for k, p of parameters.ports
					opts.HostConfig.PortBindings[k] = [{
						HostPort: p
					}]
			if parameters.environment
				opts.Env = []
				for k, v of parameters.environment
					opts.Env.push "#{k}=#{v}"
			@constructor.docker.createContainer opts, (error, container) =>
				if error
					# console.log @name
					# console.dir opts
					# console.dir error
					return d.reject error
				container.start (error) ->
					if error
						return d.reject error
					d.resolve()
			return d.promise

		start: (parameters) ->
			console.debug "#{@name}: starting"
			d = $q.defer()
			try
				@createRuntimeParameters()
			catch e
				d.reject "#{gettextCatalog.getString(gettext('Variable substitution error'))}: #{e}"
				return d.promise
			@runtime.infos.container =
				State:
					Starting: true
			@_start().then =>
				delete @runtime.infos.container.State.Starting
				@runtime.infos.container.State.Running = true
				@checkContainerStatus()
				$timeout =>
					@startLog()
				, 50
				console.debug "#{@name}: started"
				d.resolve()
			, (error) =>
				delete @runtime.infos.container.State.Starting
				d.reject error
			return d.promise

		createRuntimeParameters: ->
			# Parameters
			params = {
				hostname: @hostname if @hostname
				links: @links if @links
				ports: @ports if @ports
				mounts: angular.copy @mounts if @mounts
				environment: @environment if @environment
				cmd: @cmd if @cmd
			}
			# Variables
			vars = []
			for k, v of @variables
				vars[k] = v.value
			# Variables substitution
			@runtime.parameters = @substitute params, vars

		stop: ->
			d = $q.defer()
			@constructor.docker.getContainerByName @name, (error, container) =>
				# if @name == "core-api"
				# 	console.dir container
				# 	return d.resolve()
				if error
					@checkContainerStatus()
					return d.reject error
				if not container
					return d.resolve()
				console.debug "#{@name}: stopping"
				@runtime.infos.container.State.Stopping = true if @runtime.infos.container?
				container.remove
					force: true
					v: true
				, (error, data) =>
					delete @runtime.infos.container.State.Stopping if @runtime.infos.container?
					@stopLog()
					@checkContainerStatus()
					if error
						return d.reject error
					console.debug "#{@name}: stopped"
					d.resolve()
			return d.promise

		startLog: ->
			@stopLog() if @runtime.log.enabled

			d = $q.defer()
			@constructor.docker.getContainerByName @name, (error, container) =>
				if error
					return d.reject error
				if not container
					return d.resolve()
				container.logs
					follow: true
					stdout: true
					stderr: true
					tty: false
				, (error, stream) =>
					if error
						return d.reject error
					@runtime.log.enabled = true
					Stream = require 'stream'
					stdout = new Stream.PassThrough()
					stderr = new Stream.PassThrough()
					container.modem.demuxStream stream, stdout, stderr
					@runtime.log.streamsHandlers.stdout = stdout.on 'data', (chunk) =>
						log =
							stream: 'stdout'
							data: chunk.toString()
						@runtime.log.addToLog log
						d.notify log
					@runtime.log.streamsHandlers.stderr = stderr.on 'data', (chunk) =>
						log =
							stream: 'stderr'
							data: chunk.toString()
						@runtime.log.addToLog log
						d.notify log
			return d.promise

		stopLog: ->
			@runtime.log.streamsHandlers.stdout && @runtime.log.streamsHandlers.stdout.removeAllListeners()
			@runtime.log.streamsHandlers.stderr && @runtime.log.streamsHandlers.stderr.removeAllListeners()
			@runtime.log.enabled = false

		clearLog: ->
			@runtime.log.clearLog()

		getContainerInfos: (containerName) ->
			d = $q.defer()
			@constructor.docker.getContainerByName @name, (error, container) ->
				if error
					return d.reject error
				if not container
					return d.resolve()
				container.inspect (error, data) ->
					if error
						return d.reject error
					d.resolve data
			return d.promise

		getImageInfos: (imageName) ->
			d = $q.defer()
			result = {}
			image = @constructor.docker.getImage @image
			image.inspect (error, data) ->
				if error
					return d.reject error
				result.infos = data
				image.history (error, data) ->
					if error
						return d.reject error
					result.history = data
					d.resolve result
			return d.promise

		pullImage: (authconfig) ->
			d = $q.defer()
			opts = {}
			if authconfig
				opts.authconfig = authconfig
			@constructor.docker.pull @image, opts, (error, stream) =>
				if error
					return d.reject error
				@constructor.docker.modem.followProgress stream
				, (error, output) ->
					if error
						return d.reject error
					d.resolve output
				, (event) ->
					d.notify event
			return d.promise

	return Container

]
