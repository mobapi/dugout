app
.service 'updateMgr',
['$q', '$state', '$http',
($q, $state, $http) ->

	class Service

		checkUpdate: ->
			pkg = require './package.json'
			@getLastVersion().then (version) ->
				if version > pkg.version
					$state.go 'about'

		getLastVersion: ->
			d = $q.defer()
			$http.get 'https://api.github.com/repos/mobapi/dugout/releases'
			.then (response) ->
				lastRelease = response?.data?[0]
				if lastRelease?.target_commitish == 'master'
					d.resolve lastRelease.tag_name.replace 'v', ''
			, d.reject
			return d.promise

	return new Service()

]
