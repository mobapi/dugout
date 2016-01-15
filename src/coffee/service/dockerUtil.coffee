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
					All: true
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
					if not matched.length
						return cb "Not found"
					container = matched[0]
					container = @getContainer container.Id
					return cb null, container
			if @globalConf.docker.connectionType == 'socket'
				@docker = new Docker
					socketPath: "#{@globalConf.docker.socket}"
			else if @globalConf.docker.connectionType == 'tcpip'
				options = {
					host: @globalConf.docker.address
					port: @globalConf.docker.port
				}
				if @globalConf.docker.secure
					fs = require 'fs'
					options.ca = fs.readFileSync "#{@globalConf.docker.certPath}/ca.pem"
					options.cert = fs.readFileSync "#{@globalConf.docker.certPath}/cert.pem"
					options.key = fs.readFileSync "#{@globalConf.docker.certPath}/key.pem"
				@docker = new Docker options

		startContainer: (containerName, imageName, parameters) ->
			q = $q.defer()
			if globalConfMgr.isConfigurationValid()
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
				@docker.createContainer opts, (error, container) ->
					if error
						return q.reject error
					container.start (error) ->
						if error
							return q.reject error
						q.resolve()
			else
				q.reject()
			return q.promise

		stopContainer: (containerName) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			@docker.getContainerByName containerName
			, (error, container) ->
				if error
					return q.reject error
				container.stop (error) ->
					if error
						return q.reject error
					container.remove null, (error) ->
						if error
							return q.reject error
						q.resolve()
			return q.promise

		startContainerLog: (containerName) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			@docker.getContainerByName containerName
			, (error, container) ->
				if error
					return q.reject error
				container.logs
					follow: true
					stdout: true
					stderr: true
					tty: false
				, (error, stream) ->
					if error
						return q.reject error
					Stream = require 'stream'
					stdout = new Stream.PassThrough()
					stderr = new Stream.PassThrough()
					container.modem.demuxStream stream, stdout, stderr
					stdout.on 'data', (chunk) ->
						q.notify chunk.toString()
			return q.promise

		# stopContainerLog: (containerName) ->
		# 	q = $q.defer()
		# 	return q.reject() if not @globalConf
		# 	return q.promise

		getContainerInfos: (containerName) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			@docker.getContainerByName containerName
			, (error, container) ->
				if error
					return q.reject error
				container.inspect (error, data) ->
					if error
						return q.reject error
					q.resolve data
			return q.promise

		getImageInfos: (imageName) ->
			q = $q.defer()
			result = {}
			image = @docker.getImage imageName
			image.inspect (error, data) ->
				if error
					return q.reject error
				result.infos = data
				image.history (error, data) ->
					if error
						return q.reject error
					result.history = data
					q.resolve result
			return q.promise

		pullImage: (imageName) ->
			q = $q.defer()
			@docker.pull imageName, (error, stream) =>
				if error
					return q.reject error
				# stream.on 'readable', ->
				# 	while((chunk = stream.read()) != null)
				# 		q.notify JSON.parse(chunk.toString())
				# stream.on 'end', ->
				# 	q.resolve()
				@docker.modem.followProgress stream
				, (error, output) ->
					if error
						return q.reject error
					q.resolve output
				, (event) ->
					q.notify event
			return q.promise


	return new Service()

]
