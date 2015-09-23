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
				docker:
					image: {}
					container:
						addToLog: (data) ->
							@log = "" if not @log
							@log += data
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
				dockerUtil.getContainerInfos(@id).then (infos) =>
					@runtime.docker.container.infos = infos
					q.resolve()
				, (error) =>
					delete @runtime.docker.container.infos
					q.reject error
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
			# Create container
			dockerUtil.createContainer(@id, @image, @docker_cmd, @runtime.params).then =>
				# And start it !
				dockerUtil.startContainer(@id).then =>
					@startContainerLog()
					@checkContainerStatus()
				, (error) =>
					console.error "Unable to start container: error #{error}"
					@checkContainerStatus()
			, (error) =>
				console.error "Unable to create container: error #{error}"
				@checkContainerStatus()
			, (data) =>
				@checkContainerStatus()
				@runtime.docker.container.addToLog data.stdout.toString() if data.stdout
				@runtime.docker.container.addToLog data.stderr.toString() if data.stderr

		stopContainer: ->
			dockerUtil.stopContainer(@id).then =>
				@stopContainerLog()
				@checkContainerStatus()
			, (error) =>
				console.dir error
				@checkContainerStatus()

		startContainerLog: ->
			return if @runtime.docker.container.logging
			dockerUtil.startContainerLog(@id).then =>
				@runtime.docker.container.logging = true
			, (error) =>
				console.dir error
			, (data) =>
				@runtime.docker.container.logging = true
				@runtime.docker.container.addToLog data.stdout.toString() if data.stdout

		stopContainerLog: ->
			dockerUtil.stopContainerLog(@id).then =>
				delete @runtime.docker.container.log
				@runtime.docker.container.logging = false
			, (error) =>
				console.dir error

		pullImage: ->
			d = $q.defer()
			dockerUtil.pullImage(@image).then d.resolve, d.reject
			, (data) =>
				d.notify data.stdout.toString()
			return d.promise

	return Project

]
