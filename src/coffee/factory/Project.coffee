app
.factory 'Project',
['$q', 'dockerUtil',
($q, dockerUtil) ->

	class Project

		constructor: (@id, conf) ->
			angular.extend @, conf
			@runtime = {
				globalConf: {}
				configurationValid: false
				docker: {}
			}

		checkConfiguration: ->
			@runtime.configurationValid = false
			if @variables
				for variableName, variable of @variables
					return @runtime.configurationValid if variable.mandatory and not variable.value
			@runtime.configurationValid = true
			return @runtime.configurationValid

		checkContainerStatus: ->
			q = $q.defer()
			dockerUtil.getImageInfos(@image).then (infos) =>
				@runtime.docker.image = infos
				dockerUtil.getContainerStatus(@id).then (status) =>
					if status
						console.log "Container #{@id} is up"
						# @runtime.docker = {} if not @runtime.docker
						dockerUtil.getContainerInfos(@id).then (infos) =>
							# angular.extend @runtime.docker.container, infos
							@runtime.docker.container = infos
							q.resolve()
						, (error) =>
							q.reject error
						@startContainerLog()
					else
						console.log "Container #{@id} is down"
						delete @runtime.docker.container
						@stopContainerLog()
						q.resolve()
			, (error) =>
				q.reject error
			return q.promise

		substitute: (params, vars) ->
			out = {}
			for kp, p of params
				if typeof p == 'object'
					out[kp] = @substitute params[kp], vars
				else
					out[kp] = _.template(p)(vars)
			return out

		startContainer: ->
			# Parameters
			params = {
				hostname: @hostname if @hostname
				links: @links if @links
				ports: @ports if @ports
				volumes: angular.copy @volumes if @volumes
				cmd: @cmd if @cmd
			}
			# Variables
			vars = {}
			for k, v of @variables
				vars[k] = v.value
			# Variables substitution
			@runtime.params = @substitute params, vars
			# Start !
			dockerUtil.startContainer(@id, @image, @docker_cmd, @runtime.params).then null
			, (error) =>
				console.error "Unable to start container: error #{error}"
				@checkContainerStatus()
			, (data) =>
				@checkContainerStatus()
				@runtime.containerLog = "" if not @runtime.containerLog
				@runtime.imageLog += data.stdout.toString() if data.stdout
				@runtime.containerLog += data.stderr.toString() if data.stderr

		stopContainer: ->
			dockerUtil.stopContainer(@id).then =>
				@checkContainerStatus()
			, (error) =>
				console.dir error
				@checkContainerStatus()

		startContainerLog: ->
			# @runtime.containerLogProcess = process
			@runtime.containerLog = ""
			dockerUtil.startContainerLog(@id).then null
			, =>
				# delete @runtime.containerLogProcess if @runtime.containerLogProcess
				delete @runtime.containerLog if @runtime.containerLog
			, (data) =>
				@runtime.containerLog = "" if not @runtime.containerLog
				@runtime.containerLog += data.stdout.toString() if data.stdout
				# @runtime.containerLog += data.stderr.toString() if data.stderr

		stopContainerLog: ->
			return
			# dockerUtil.stopContainerLog(@runtime.containerLogProcess).then =>
			# 	delete @runtime.containerLogProcess
			# 	delete @runtime.containerLog

		pullImage: ->
			d = $q.defer()
			dockerUtil.pullImage(@image).then d.resolve, d.reject
			, (data) =>
				d.notify data.stdout.toString()
			return d.promise

	return Project

]
