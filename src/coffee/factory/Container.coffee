app
.factory 'Container',
['$q', 'dockerUtil',
($q, dockerUtil) ->

	class Container

		constructor: (@id, conf) ->
			angular.extend @, conf
			@runtime =
				globalConf: {}
				configurationValid: false
				docker:
					image: {}
					container:
						addToLog: (log) ->
							@clearLog() if not @log
							@log[log.stream] += log.data
						clearLog: ->
							@log =
								stdout: ""
								stderr: ""

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
					if p.length
						out[kp] = []
						for a, k in p
							out[kp][k] = @substitute params[kp][k], vars
					else
						out[kp] = @substitute params[kp], vars
				else
					out[kp] = _.template(p)(vars)
			return out

		startContainer: ->
			d = $q.defer()
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
			vars = {}
			for k, v of @variables
				vars[k] = v.value
			# Variables substitution
			try
				@runtime.params = @substitute params, vars
			catch e
				d.reject "#{gettextCatalog.getString(gettext('Variable substitution error'))}: #{e}"
				return d.promise
			# Create container
			dockerUtil.startContainer(@id, @image, @runtime.params).then (container) =>
				delete @runtime.docker.container.infos.State.Starting
				@runtime.docker.container.infos.State.Running = true
				@checkContainerStatus()
				@startContainerLog()
				d.resolve()
			, (error) =>
				console.error "Unable to create or start container: error #{error}"
				@checkContainerStatus()
				d.reject error
			@runtime.docker.container.infos =
				State:
					Starting: true
			return d.promise

		stopContainer: ->
			d = $q.defer()
			dockerUtil.stopContainer(@id).then =>
				@stopContainerLog(@id)
				@checkContainerStatus()
				d.resolve()
			, (error) =>
				console.dir error
				@checkContainerStatus()
				d.reject()
			if @runtime.docker.container.infos
				@runtime.docker.container.infos.State.Stopping = true
			return d.promise

		startContainerLog: ->
			@stopContainerLog() if @runtime.docker.container.logging
			dockerUtil.startContainerLog(@id).then =>
				@runtime.docker.container.logging = true
			, (error) =>
				console.dir error
			, (data) =>
				@runtime.docker.container.logging = true
				@runtime.docker.container.addToLog data if data

		stopContainerLog: ->
			@runtime.docker.container.logging = false

		clearContainerLog: ->
			@runtime.docker.container.clearLog()

		pullImage: ->
			d = $q.defer()
			dockerUtil.pullImage(@image).then d.resolve, d.reject, d.notify
			return d.promise

	return Container

]
