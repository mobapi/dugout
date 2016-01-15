app
.service 'filesMgr',
['$rootScope', '$q', 'localStorageService',
($rootScope, $q, storage) ->

	class Service

		maxRecentFiles: 20
		currentFile: null

		loadConfigurationFile: (filePath) ->
			d = $q.defer()
			@loadFileContent(filePath).then (content) =>
				try
					data = JSON.parse content
				catch e
					return d.reject sprintf(gettextCatalog.getString(gettext('File %(file)s is not a valid json file')),
						file: filePath
					)
				if not data
					return d.reject sprintf(gettextCatalog.getString(gettext('File %(file)s is empty')),
						file: filePath
					)
				@currentFile = filePath
				@addRecentFile filePath
				data.path = filePath
				d.resolve data
			, d.reject
			return d.promise

		loadFileContent: (file) ->
			d = $q.defer()
			fs = require 'fs'
			fs.readFile file, 'utf8', (error, content) ->
				return d.reject error if error
				d.resolve content
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
