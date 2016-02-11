app
.factory 'Container',
['$q', 'globalConfMgr',
($q, globalConfMgr) ->

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
					options.ca = fs.readFileSync "#{@globalConf.docker.certPath}/ca.pem"
					options.cert = fs.readFileSync "#{@globalConf.docker.certPath}/cert.pem"
					options.key = fs.readFileSync "#{@globalConf.docker.certPath}/key.pem"
				@docker = new Docker options

		constructor: (@id, conf) ->
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
				@getContainerInfos(@id).then (infos) =>
					@runtime.infos.container.infos = infos
					q.resolve()
				, (error) =>
					delete @runtime.infos.container.infos
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

		_start: () ->
			d = $q.defer()
			parameters = @runtime.parameters
			opts =
				name: @id
				Image: @image
				# Tty: true
				Hostname: @id
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
					return d.reject error
				container.start (error) ->
					if error
						return d.reject error
					d.resolve()
			return d.promise

		start: (parameters) ->
			d = $q.defer()
			# First search if the container is already present
			# If so, kill it
			@stop().then =>
				try
					@createRuntimeParameters()
				catch e
					d.reject "#{gettextCatalog.getString(gettext('Variable substitution error'))}: #{e}"
					return d.promise
				@runtime.infos.container.infos =
					State:
						Starting: true
				@_start().then =>
					delete @runtime.infos.container.infos.State.Starting
					@runtime.infos.container.infos.State.Running = true
					@checkContainerStatus()
					@startLog()
					d.resolve()
				, (error) =>
					delete @runtime.infos.container.infos.State.Starting
					d.reject error
			, d.reject
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
			@constructor.docker.getContainerByName @id, (error, container) =>
				if error
					@checkContainerStatus()
					return d.reject error
				if not container
					return d.resolve()
				if @runtime.infos.container.infos
					@runtime.infos.container.infos.State.Stopping = true
				@stopLog()
				container.remove
					force: true
					v: true
				, (error, data) =>
					if error
						@checkContainerStatus()
						return d.reject error
					@checkContainerStatus()
					d.resolve()
			return d.promise

		startLog: ->
			@stopLog() if @runtime.log.enabled

			d = $q.defer()
			@constructor.docker.getContainerByName @id, (error, container) =>
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
						setTimeout =>
							console.log 'add'
							@runtime.log.addToLog
								stream: 'stdout'
								data: chunk.toString()
						, 50
						d.notify()
					@runtime.log.streamsHandlers.stderr = stderr.on 'data', (chunk) =>
						@runtime.log.addToLog
							stream: 'stderr'
							data: chunk.toString()
						d.notify()
			return d.promise

		stopLog: ->
			@runtime.log.streamsHandlers.stdout && @runtime.log.streamsHandlers.stdout.removeAllListeners()
			@runtime.log.streamsHandlers.stderr && @runtime.log.streamsHandlers.stderr.removeAllListeners()
			@runtime.log.enabled = false

		clearLog: ->
			@runtime.log.clearLog()

		getContainerInfos: (containerName) ->
			d = $q.defer()
			@constructor.docker.getContainerByName @id, (error, container) ->
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
