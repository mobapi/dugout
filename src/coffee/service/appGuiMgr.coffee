app
.service 'appGuiMgr',
['$rootScope', 'toaster', 'filesMgr', 'containersMgr',
($rootScope, toaster, filesMgr, containersMgr) ->

	class Service

		constructor: ->
			@gui = require 'nw.gui'
			@window = @gui.Window.get()
			$rootScope.$on 'recentFilesChanged', (event, data) =>
				@createPopupMenu data.currentFile, data.recentFiles

		createMenu: ->
			if window.process.platform != 'darwin'
				return

			menubar = new @gui.Menu
				type: 'menubar'
			
			menubar.createMacBuiltin 'Dugout',
				hideEdit: false
				hideWindow: false

			@window.menu = menubar

		createPopupMenu: (currentFile, recentFiles) ->
			@popupMenu = new @gui.Menu()
			openConfigurationFileMenuItem = new @gui.MenuItem
				label: gettextCatalog.getString gettext('Open...')
				tooltip: gettextCatalog.getString gettext('Open containers configuration file')
				key: 'o'
				modifiers: 'ctrl'
			openConfigurationFileMenuItem.click = ->
				input = $('#openConfigurationFile')
				evt = input.on 'change', ->
					filesMgr.loadConfigurationFile @value
					.then (data) ->
						containersMgr.stopAll()
						containersMgr.init data
					, (error) ->
						toaster.pop
							type: 'error'
							title: gettextCatalog.getString gettext('Error')
							body: error
				input[0].click()
			@popupMenu.append openConfigurationFileMenuItem
			@popupMenu.append new @gui.MenuItem
				type: 'separator'
			# Current file
			if currentFile
				menuItem = new @gui.MenuItem
					label: sprintf gettextCatalog.getString(gettext('Current file: %(file)s')),
						file: currentFile
					enabled: false
				@popupMenu.append menuItem
				@popupMenu.append new @gui.MenuItem
					type: 'separator'
			# Recent files
			if recentFiles.length
				menuItem = new @gui.MenuItem
					label: gettextCatalog.getString(gettext('Recent files'))
					enabled: false
				@popupMenu.append menuItem
				for recentFile in recentFiles
					((recentFile) =>
						menuItem = new @gui.MenuItem
							label: recentFile
						menuItem.click = ->
							filesMgr.loadConfigurationFile recentFile
							.then (data) ->
								containersMgr.stopAll()
								containersMgr.init data
						@popupMenu.append menuItem
					)(recentFile)
				# Clear recent files
				@popupMenu.append new @gui.MenuItem
					type: 'separator'
				menuItem = new @gui.MenuItem
					label: gettextCatalog.getString gettext('Clear recent files')
				menuItem.click = ->
					filesMgr.clearRecentFiles()
				@popupMenu.append menuItem

		openPopupMenu: (x, y) ->
			@popupMenu.popup x, y

		showDevTools: ->
			@window.showDevTools()

		closeApp: ->
			@window.close()

		minimizeApp: ->
			@window.minimize()

		maximizeApp: ->
			@window.maximize()

		openExternalLink: (url) ->
			@gui.Shell.openExternal url

	return new Service()

]
