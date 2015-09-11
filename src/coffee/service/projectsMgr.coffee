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
				project.checkContainerStatus().then null, (error) ->
					console.error error
				# Add project to projects list
				@projects[id] = project
			# console.dir @projects

		get: (id) ->
			return @projects[id]

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
