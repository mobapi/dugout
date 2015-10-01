( ->

	modules = [ 'dugout' ]

	ngBootstrap = ->
		htmlElement = document.querySelector 'html'
		angular.bootstrap htmlElement, modules

	document.onreadystatechange = ->
		if document.readyState == 'complete'
			ngBootstrap()

)()
