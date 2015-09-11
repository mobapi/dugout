app
.directive 'externalLink', ['appGuiMgr', (appGuiMgr) ->
	
	class Directive

		restrict: 'A'

		link: (scope, element, attrs, transclude) ->
			element.on 'click', (event) ->
				event.preventDefault()
				appGuiMgr.openExternalLink event.target.href

	return new Directive()

]
