( ->

	modules = [ 'dugout' ]

	ngBootstrap = ->
		htmlElement = document.querySelector 'html'
		angular.bootstrap htmlElement, modules

	if window.cordova?
		document.addEventListener 'deviceready', ->
			ngBootstrap()
		, false
	else
		document.onreadystatechange = ->
			if document.readyState == 'complete'
				ngBootstrap()

)()
