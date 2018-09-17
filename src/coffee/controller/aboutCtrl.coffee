app
.controller 'aboutCtrl',
['$scope', 'updateMgr',
($scope, updateMgr) ->

	class Controller

		constructor: ->
			$scope.pkg = require './package.json'
			updateMgr.getLastVersion().then (version) ->
				$scope.lastVersion = version
			$scope.nw_libs = _(process.versions).toPairs().sortBy(0).fromPairs().value()

	return new Controller()

]
