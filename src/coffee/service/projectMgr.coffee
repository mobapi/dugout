app
.service 'projectMgr',
['containersMgr',
(containersMgr) ->

	class Service

		constructor: ->
			@project = {}

		init: (project) ->
			@project.path = project.path
			@project.name = project.name
			@project.version = project.version
			containersMgr.init project.containers
			@project.containers = containersMgr.containers

		stop: ->
			containersMgr.stopAll()

	return new Service()

]
