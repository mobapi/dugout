app
.service 'containersMgr',
['$rootScope', '$q', '$http', 'toaster', 'localStorageService', 'filesMgr','Container',
($rootScope, $q, $http, toaster, storage, filesMgr, Container) ->

	class Service

		constructor: ->
			@containers = {}

		init: (containers) ->
			# Reset containers array
			for k, p of @containers
				delete @containers[k]
			for id, p of containers
				# Create container object from static configuration
				container = new Container id, p
				# Check container configuration
				container.checkConfiguration()
				# Docker status
				container.checkContainerStatus()
				# Add container to containers list
				@containers[id] = container
			# console.dir @containers

		get: (id) ->
			return @containers[id]

		start: (container) ->
			d = $q.defer()
			tasks = []
			for link, k of container.links
				subcontainer = @containers[k]
				((subcontainer) =>
					tasks.push (callback) =>
						if subcontainer.runtime.docker.container.infos
							return callback null, subcontainer
						else
							@start subcontainer
							.then ->
								callback null, subcontainer
							, (error) ->
								callback error
				)(subcontainer)
			async.parallel tasks, (error, results) ->
				return d.reject error if error
					# console.dir
					# 	error: error
					# 	results: results
				if results.length == tasks.length
					container.startContainer().then ->
						d.resolve()
					, (error) ->
						toaster.pop
							type: 'error'
							title: gettextCatalog.getString gettext('Error')
							body: "Unable to create container: #{error}"
						d.reject error
			return d.promise

		stop: (container) ->
			container.stopContainer()

		startAll: ->
			for name, container of @containers
				container.startContainer()			

		stopAll: ->
			for name, container of @containers
				container.stopContainer()

		save: ->
			containers = angular.copy @containers
			for k, p of containers
				delete containers[k].runtime
			fileContent = JSON.stringify containers
			beautify = require('js-beautify').js_beautify
			fileContent = beautify fileContent, 
				indent_with_tabs: true
			fs = require 'fs'
			fs.writeFileSync filesMgr.currentFile, fileContent

	return new Service()

]
