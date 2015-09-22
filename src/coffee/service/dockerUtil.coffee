app
.service 'dockerUtil',
['$q', 'process', 'globalConfMgr',
($q, process, globalConfMgr) ->

	class Service

		globalConf: {}

		init: ->
			@globalConf = globalConfMgr.conf

		buildDockerEnv: ->
			return if not @globalConf
			if @globalConf.docker.connectionType == 'socket'
				return {
					DOCKER_HOST: "unix://#{@globalConf.docker.socket}"
				}
			else if @globalConf.docker.connectionType == 'tcpip'
				return {
					DOCKER_HOST: _.template("${protocol}://${address}:${port}")({
						protocol: 'tcp'
						address: @globalConf.docker.address
						port: @globalConf.docker.port
					})
					DOCKER_TLS_VERIFY: 1 if @globalConf.docker.secure
					DOCKER_CERT_PATH: @globalConf.docker.certPath
				}

		# getContainerStatus: (containerName) ->
		# 	q = $q.defer()
		# 	if globalConfMgr.isConfigurationValid()
		# 		cmd = "#{@globalConf.dockerCommand} inspect --type=container #{containerName}"
		# 		process.exec(cmd, @buildDockerEnv()).then (stdout, stderr) =>
		# 			q.resolve true
		# 		, (error, stderr) =>
		# 			q.resolve false
		# 	else
		# 		q.reject()
		# 	return q.promise

		createContainer: (containerName, imageName, cmd, parameters) ->
			q = $q.defer()
			if globalConfMgr.isConfigurationValid()
				cmdline = []
				cmdline.push @globalConf.dockerCommand
				cmdline.push "create"
				cmdline.push "--name"
				cmdline.push containerName
				# Host name
				if parameters.hostname
					cmdline.push "--hostname"
					cmdline.push parameters.hostname
				else
					cmdline.push "--hostname"
					cmdline.push containerName
				# Links
				if parameters.links
					for k, v of parameters.links
						cmdline.push "--link"
						cmdline.push "#{v}:#{k}"
				# Ports redirections
				if parameters.ports
					for k, v of parameters.ports
						cmdline.push "--publish"
						cmdline.push "#{v}:#{k}"
				# Volumes
				if parameters.volumes
					for k, v of parameters.volumes
						cmdline.push "--volume"
						cmdline.push "#{v}:#{k}"
				# Image
				cmdline.push imageName
				# Command
				if parameters.cmd
					cmdline.push "/bin/bash"
					cmdline.push "-c"
					cmdline.push parameters.cmd
				# Start the process
				process.spawn cmdline[0], cmdline.slice(1), @buildDockerEnv()
				.then q.resolve, q.reject, q.notify
			else
				q.reject()
			return q.promise

		startContainer: (containerName) ->
			q = $q.defer()
			if globalConfMgr.isConfigurationValid()
				cmdline = []
				cmdline.push @globalConf.dockerCommand
				cmdline.push "start"
				cmdline.push containerName
				# Start the process
				process.spawn cmdline[0], cmdline.slice(1), @buildDockerEnv()
				.then q.resolve, q.reject, q.notify
			else
				q.reject()
			return q.promise

		stopContainer: (containerName) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			cmd = "#{@globalConf.dockerCommand} rm -f #{containerName}"
			process.exec(cmd, @buildDockerEnv()).then (stdout, stderr) =>
				# @stopContainerLog()
				q.resolve()
			, (error, stderr) =>
				q.reject error
			return q.promise

		startContainerLog: (containerName) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			process.spawn(@globalConf.dockerCommand, [ 'logs', '-f', containerName ], @buildDockerEnv()).then null, q.reject, q.notify
			return q.promise

		stopContainerLog: (containerLogProcess) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			if containerLogProcess
				ret = containerLogProcess.kill()
				console.log "kill #{containerLogProcess.pid} => #{ret}"
				q.resolve()
			else
				q.reject()
			return q.promise

		getContainerInfos: (containerName) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			@inspectContainer(containerName).then (containerInfos) =>
				infos = JSON.parse containerInfos
				q.resolve infos[0]
			, (error, stderr) ->
				q.reject error, stderr
			return q.promise

		inspectContainer: (containerName) ->
			q = $q.defer()
			return q.reject() if not @globalConf
			cmd = "#{@globalConf.dockerCommand} inspect --type=container #{containerName}"
			process.exec(cmd, @buildDockerEnv()).then (stdout, stderr) =>
				q.resolve stdout
			, (error, stderr) =>
				q.reject error, stderr
			return q.promise

		getImageInfos: (imageName) ->
			q = $q.defer()
			result = {}
			# Container & image infos
			@inspectImage(imageName).then (imageInfos) =>
				result.infos = imageInfos
				@getImageHistory(imageName).then (imageHistory) =>
					result.history = imageHistory
					q.resolve result
				, (error, stderr) ->
					q.reject error, stderr
			, (error, stderr) ->
				q.reject error, stderr
			return q.promise

		inspectImage: (imageName) ->
			q = $q.defer()
			cmd = "#{@globalConf.dockerCommand} inspect --type=image #{imageName}"
			process.exec(cmd, @buildDockerEnv()).then (stdout, stderr) =>
				q.resolve stdout
			, (error, stderr) =>
				q.reject error, stderr
			return q.promise

		getImageHistory: (imageName) ->
			q = $q.defer()
			cmd = "#{@globalConf.dockerCommand} history #{imageName}"
			process.exec(cmd, @buildDockerEnv()).then (stdout, stderr) =>
				q.resolve stdout
			, (error, stderr) =>
				q.reject error, stderr
			return q.promise

		pullImage: (imageName) ->
			q = $q.defer()
			cmd = "#{@globalConf.dockerCommand} pull #{imageName}"
			sp = cmd.split ' '
			process.spawn(sp[0], sp.slice(1), @buildDockerEnv()).then q.resolve, q.reject, q.notify
			return q.promise


	return new Service()

]
