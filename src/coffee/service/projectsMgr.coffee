app
.service 'projectsMgr',
['$q', '$http', 'localStorageService', 'Project',
($q, $http, storage, Project) ->

	class Service

		constructor: ->
			@projects = {}

		init: (projects) ->
			# Reset projects array
			for k, p of @projects
				delete @projects[k]
			# Previously saved projects data
			projectsFromStorage = storage.get 'projects'
			if not projects and projectsFromStorage
				projects = projectsFromStorage
			for id, p of projects
				# Create project object from static configuration
				project = new Project id, p
				# Check project configuration
				project.checkConfiguration()
				# Docker status
				project.checkContainerStatus()
				# Add project to projects list
				@projects[id] = project
			# console.dir @projects

		get: (id) ->
			return @projects[id]

		start: (project) ->
			d = $q.defer()
			tasks = []
			for link, k of project.links
				subproject = @projects[k]
				((subproject) =>
					tasks.push (callback) =>
						if subproject.runtime.docker.container.infos
							return callback null, subproject
						else
							@start subproject
							.then ->
								callback null, subproject
							, (error) ->
								callback error
				)(subproject)
			async.parallel tasks, (error, results) ->
				if error
					console.dir
						error: error
						results: results
				if results.length == tasks.length
					project.startContainer().then ->
						d.resolve()
					, (error) ->
						d.reject()
			return d.promise

		stop: (project) ->
			project.stopContainer()

		startAll: ->
			for name, project of @projects
				project.startContainer()			

		stopAll: ->
			for name, project of @projects
				project.stopContainer()

		save: ->
			projects = angular.copy @projects
			for k, p of projects
				delete projects[k].runtime
			storage.set 'projects', projects

	return new Service()

]
