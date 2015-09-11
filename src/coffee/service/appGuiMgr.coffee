app
.service 'appGuiMgr',
[ ->


	class Service

		constructor: ->
			@gui = require 'nw.gui'
			@window = @gui.Window.get()

		createMenu: ->
			if window.process.platform != 'darwin'
				return

			menubar = new @gui.Menu
				type: 'menubar'
			
			menubar.createMacBuiltin "Dugout",
				hideEdit: false
				hideWindow: false

			@window.menu = menubar

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
