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
			errors = []
			for link, k of container.links
				subcontainer = @containers[k]
				((subcontainer) =>
					tasks.push (callback) =>
						if subcontainer.runtime.docker.container.infos
							# Container is already started
							return callback null, subcontainer
						else
							# Container stopped, so start it
							@start subcontainer
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
					container.startContainer().then d.resolve, (error) ->
						errors.push
							container: container
							error: error
						toaster.pop
							type: 'error'
							title: gettextCatalog.getString gettext('Error')
							body: "Unable to create container: #{error}"
						d.reject errors
			return d.promise

		stop: (container) ->
			container.stopContainer()

		stopAll: ->
			d = $q.defer()
			tasks = []
			for containerId, container of @containers
				((container) =>
					tasks.push (callback) =>
						container.stopContainer().then ->
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
