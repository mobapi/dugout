app
.service 'filesMgr',
['$rootScope', '$q', 'localStorageService',
($rootScope, $q, storage) ->

	crypto = require 'crypto'
	fs = require 'fs'
	path = require 'path'

	class Service

		maxRecentFiles: 20
		currentFile: null

		loadProject: (filePath) ->
			d = $q.defer()
			tasks = [
				# Load project file
				(cb) =>
					fs.readFile filePath, 'utf8', (error, content) ->
						if error
							return cb error
						try
							projectConfiguration = JSON.parse content
							if not projectConfiguration
								return cb sprintf(gettextCatalog.getString(gettext('File %(file)s is empty')),
									file: filePath
								)
							for containerName, containerConfiguration of projectConfiguration.containers
								projectConfiguration.containers[containerName].variablesLength = Object.keys(containerConfiguration.variables || {}).length
							cb null, projectConfiguration
						catch e
							return cb sprintf(gettextCatalog.getString(gettext('File %(file)s is not a valid json file')),
								file: filePath
							)
				# Load project variables
				(projectConfiguration, cb) =>
					filename = path.join(nw.App.dataPath, "projects", filePath.replace(new RegExp(path.sep, "g"), '_'))
					fs.readFile filename, 'utf8', (error, content) ->
						if error
							if error.code == 'ENOENT'
								return cb null, projectConfiguration
							return cb error
						try
							content = JSON.parse content
							for containerName, containerConfiguration of projectConfiguration.containers
								if containerConfiguration.variablesLength
									containerVariablesValues = content[containerName]
									for variableName, variableConfiguration of containerConfiguration.variables
										projectConfiguration.containers[containerName].variables[variableName].value = containerVariablesValues[variableName]
						catch e
							cb e
						cb null, projectConfiguration
			]
			async.waterfall tasks, (error, projectConfiguration) =>
				if error
					return d.reject error
				@currentFile = filePath
				@addRecentFile filePath
				projectConfiguration.path = filePath
				d.resolve projectConfiguration
			return d.promise

		saveProject: (project) ->
			d = $q.defer()
			project = angular.copy project
			containersVariables = {}
			for containerName, container of project.containers
				containersVariables[containerName] = {}
				for variableName, variable of container.variables
					containersVariables[container.name][variableName] = variable.value
			fileContent = JSON.stringify containersVariables, null, 2
			fs.mkdir path.join(nw.App.dataPath, "projects"), (error) =>
				if error and error.code != "EEXIST"
					return d.reject error
				filename = path.join(nw.App.dataPath, "projects", @currentFile.replace(new RegExp(path.sep, "g"), '_'))
				fs.writeFile filename, fileContent, (error) ->
					if error
						console.dir error
						return d.reject error
					d.resolve()
			return d.promise

		addRecentFile: (recentFilePath) ->
			recentFiles = storage.get('recentConfigurationFiles') || []
			return if recentFiles.length and recentFiles[0] == recentFilePath
			i = recentFiles.indexOf recentFilePath
			if i >= 0
				recentFiles.splice i, 1
			recentFiles.unshift recentFilePath
			if recentFiles.length >= @maxRecentFiles
				recentFiles = recentFiles.slice 0, @maxRecentFiles
			storage.set 'recentConfigurationFiles', recentFiles
			$rootScope.$emit 'recentFilesChanged',
				currentFile: recentFilePath
				recentFiles: recentFiles

		loadRecentFiles: ->
			recentFiles = storage.get('recentConfigurationFiles') || []
			$rootScope.$emit 'recentFilesChanged',
				currentFile: @currentFile
				recentFiles: recentFiles
			return recentFiles

		clearRecentFiles: ->
			recentFiles = []
			storage.set 'recentConfigurationFiles', recentFiles
			$rootScope.$emit 'recentFilesChanged',
				currentFile: null
				recentFiles: recentFiles

	return new Service()

]
