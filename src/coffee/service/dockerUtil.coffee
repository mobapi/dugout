app
.service 'dockerUtil',
['$q', 'globalConfMgr',
($q, globalConfMgr) ->

	class Service

		globalConf: {}

		init: ->
			@globalConf = globalConfMgr.conf
			@buildDockerObj()

		buildDockerObj: ->
			return if not @globalConf
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
			if @globalConf.docker.connectionType == 'socket'
				@docker = new Docker
					socketPath: "#{@globalConf.docker.socket}"
			else if @globalConf.docker.connectionType == 'tcpip'
				options =
					host: @globalConf.docker.address
					port: @globalConf.docker.port
				if @globalConf.docker.secure
					fs = require 'fs'
					options.ca = fs.readFileSync "#{@globalConf.docker.certPath}/ca.pem"
					options.cert = fs.readFileSync "#{@globalConf.docker.certPath}/cert.pem"
					options.key = fs.readFileSync "#{@globalConf.docker.certPath}/key.pem"
				@docker = new Docker options

		_startContainer: (containerName, imageName, parameters) ->
			d = $q.defer()
			opts =
				name: containerName
				Image: imageName
				# Tty: true
				Hostname: containerName
				HostConfig: {}
			if parameters.hostname
				opts.Hostname = parameters.hostname
			if parameters.cmd
				opts.Cmd = []
				opts.Cmd.push "sh"
				opts.Cmd.push "-c"
				opts.Cmd.push "#{parameters.cmd}"
			if parameters.mounts
				opts.Volumes = {}
				for k, v of parameters.mounts
					opts.Volumes[k] = {}
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
			@docker.createContainer opts, (error, container) =>
				if error
					return d.reject error
				container.start (error) ->
					if error
						return d.reject error
					d.resolve()
			return d.promise

		startContainer: (containerName, imageName, parameters) ->
			d = $q.defer()
			if globalConfMgr.isConfigurationValid()
				# First search if the container is already present
				# If so, kill it
				@stopContainer(containerName).then =>
					@_startContainer(containerName, imageName, parameters).then d.resolve, d.reject
				, d.reject
			else
				d.reject()
			return d.promise

		stopContainer: (containerName) ->
			d = $q.defer()
			return d.reject() if not @globalConf
			@docker.getContainerByName containerName, (error, container) ->
				if error
					return d.reject error
				if not container
					return d.resolve()
				container.remove
					force: true
					v: true
				, (error, data) =>
					if error
						return d.reject error
					d.resolve()
			return d.promise

		startContainerLog: (containerName) ->
			d = $q.defer()
			return d.reject() if not @globalConf
			@docker.getContainerByName containerName, (error, container) ->
				if error
					return d.reject error
				if not container
					return d.resolve()
				container.logs
					follow: true
					stdout: true
					stderr: true
					tty: false
				, (error, stream) ->
					if error
						return d.reject error
					Stream = require 'stream'
					stdout = new Stream.PassThrough()
					stderr = new Stream.PassThrough()
					container.modem.demuxStream stream, stdout, stderr
					stdout.on 'data', (chunk) ->
						d.notify chunk.toString()
			return d.promise

		# stopContainerLog: (containerName) ->
		# 	q = $q.defer()
		# 	return q.reject() if not @globalConf
		# 	return q.promise

		getContainerInfos: (containerName) ->
			d = $q.defer()
			return d.reject() if not @globalConf
			@docker.getContainerByName containerName, (error, container) ->
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
			image = @docker.getImage imageName
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

		pullImage: (imageName, authconfig) ->
			d = $q.defer()
			opts = {}
			if authconfig
				opts.authconfig = authconfig
			@docker.pull imageName, opts, (error, stream) =>
				if error
					return d.reject error
				@docker.modem.followProgress stream
				, (error, output) ->
					if error
						return d.reject error
					d.resolve output
				, (event) ->
					d.notify event
			return d.promise

		ping: ->
			d = $q.defer()
			return d.reject() if not @globalConf
			@docker.ping (error, data) ->
				if error
					return d.reject error
				d.resolve()
			return d.promise


	return new Service()

]
