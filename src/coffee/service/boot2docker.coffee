app
.service 'boot2docker',
['$q', 'process',
($q, process) ->

	class Boot2Docker

		getIp: ->
			defer = $q.defer()
			boot2docker = "/usr/local/bin/boot2docker"
			process.exec("#{boot2docker} ip").then (stdout, stderr) ->
				defer.resolve stdout.replace '\n', ''
			, (error, stderr) ->
				defer.reject error, stderr
			return defer.promise

	return new Boot2Docker()

]
