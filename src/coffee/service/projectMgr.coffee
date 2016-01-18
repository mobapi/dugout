app
.service 'projectMgr',
['containersMgr', 'filesMgr',
(containersMgr, filesMgr) ->

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

		save: ->
			project = angular.copy @project
			delete project.path
			for k, p of project.containers
				delete project.containers[k].runtime
			fileContent = JSON.stringify project
			beautify = require('js-beautify').js_beautify
			fileContent = beautify fileContent, 
				indent_with_tabs: true
			fs = require 'fs'
			fs.writeFileSync filesMgr.currentFile, fileContent

	return new Service()

]
