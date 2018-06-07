app
.service 'projectMgr',
['$q', '$interval', 'filesMgr', 'Container',
($q, $interval, filesMgr, Container) ->

	class Service

		constructor: ->
			@initialized = false
			@project =
				containers: {}

		init: (project) ->
			@project.path = project.path
			@project.label = project.label
			@project.version = project.version
			# Reset containers array
			for containerName of @project.containers
				delete @project.containers[containerName]
			for containerName, containerConf of project.containers
				((containerName, containerConf) =>
					# Create container object from static configuration
					container = new Container containerName, containerConf
					# Check container configuration
					container.checkConfiguration()
					# Docker status
					container.checkContainerStatus()
					# Start log
					container.startLog()
					# Add container to containers list
					@project.containers[containerName] = container
				)(containerName, containerConf)
			@initialized = true

		getContainer: (name) ->
			d = $q.defer()
			@getContainerHandler = $interval =>
				if @initialized
					$interval.cancel @getContainerHandler
					container = @project.containers[name]
					d.resolve container
			, 100
			return d.promise

		startContainer: (container) ->
			d = $q.defer()
			tasks = []
			errors = []
			if _.isObject container.links
				console.debug "Starting subcontainers: #{_.join(Object.keys(container.links), ', ')}"
			for alias, containerId of container.links
				subcontainer = @project.containers[containerId]
				((subcontainer) =>
					tasks.push (callback) =>
						if not subcontainer
							return callback gettextCatalog.getString(gettext("Container #{containerId} linked by #{container.name} was not found."))
						if subcontainer.runtime.infos.container
							console.debug "#{subcontainer.name}: already started"
							# Container is already started
							return callback null, subcontainer
						else
							# Container stopped, so start it
							@startContainer subcontainer
							.then ->
								callback null, subcontainer
							.catch (errors) ->
								console.dir errors
								callback errors[0]
				)(subcontainer)
			async.parallel tasks, (error, results) ->
				if error
					errors.push error
					return d.reject errors
				# if results.length == tasks.length
				if results.length
					console.debug "Started subcontainers: #{_.join(Object.keys(container.links), ', ')}"
				container.start().then ->
					d.resolve()
				.catch (error) ->
					errors.push
						container: container
						error: error
					d.reject errors
			return d.promise

		stop: ->
			d = $q.defer()
			tasks = []
			for containerName, container of @project.containers
				((container) =>
					tasks.push (callback) =>
						container.stop().then ->
							callback null
						, (error) ->
							callback error
				)(container)
			async.parallel tasks, (error, results) ->
				return d.reject error if error
				if results.length == tasks.length
					d.resolve()
			return d.promise

		save: ->
			filesMgr.saveProject @project

	return new Service()

]
