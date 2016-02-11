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
			@project.name = project.name
			@project.version = project.version
			# Reset containers array
			for id, p of @project.containers
				delete @project.containers[id]
			for id, containerConf of project.containers
				((id, containerConf) =>
					# Create container object from static configuration
					container = new Container id, containerConf
					# Check container configuration
					container.checkConfiguration()
					# Docker status
					container.checkContainerStatus()
					# Start log
					container.startLog()
					# Add container to containers list
					@project.containers[id] = container
				)(id, containerConf)
			@initialized = true

		getContainer: (id) ->
			d = $q.defer()
			@getContainerHandler = $interval =>
				if @initialized
					$interval.cancel @getContainerHandler
					container = @project.containers[id]
					d.resolve container
			, 100
			return d.promise

		startContainer: (container) ->
			d = $q.defer()
			tasks = []
			errors = []
			for link, k of container.links
				subcontainer = @project.containers[k]
				((subcontainer) =>
					tasks.push (callback) =>
						if subcontainer.runtime.infos.container
							# Container is already started
							return callback null, subcontainer
						else
							# Container stopped, so start it
							@startContainer subcontainer
							.then ->
								callback null, subcontainer
							, (errors) ->
								callback errors[0]
				)(subcontainer)
			async.parallel tasks, (error, results) ->
				if error
					errors.push error
					return d.reject errors
				if results.length == tasks.length
					container.start().then d.resolve, (error) ->
						errors.push
							container: container
							error: error
						d.reject errors
			return d.promise

		stop: ->
			d = $q.defer()
			tasks = []
			for containerId, container of @project.containers
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
			project = angular.copy @project
			delete project.path
			for k, p of project.containers
				delete project.containers[k].runtime
				delete project.containers[k].id
			fileContent = JSON.stringify project
			beautify = require('js-beautify').js_beautify
			fileContent = beautify fileContent, 
				indent_with_tabs: true
			fs = require 'fs'
			fs.writeFileSync filesMgr.currentFile, fileContent

	return new Service()

]
