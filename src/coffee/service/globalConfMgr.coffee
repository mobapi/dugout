app
.service 'globalConfMgr',
['$q', 'process', 'boot2docker', 'localStorageService',
($q, process, boot2docker, storage) ->

	class Service

		conf: null
		valid: false

		constructor: ->
			@load()
			language = @conf.language
			if not language
				language = navigator.language || navigator.userLanguage
			if not language
				language = 'en'
			@setLanguage language

		# getLanguage: ->
		# 	try
		# 		language = JSON.parse storage.get 'language'
		# 	return language

		setLanguage: (language) ->
			# $rootScope.language = language
			@conf.language = language
			gettextCatalog.setCurrentLanguage language
			@save()
			# storage.set 'language', JSON.stringify language

		removeLanguage: ->
			storage.remove 'language'


		# getDockerIp: ->
		# 	defer = $q.defer()
		# 	boot2docker.getIp().then (ip) ->
		# 		defer.resolve ip
		# 	return defer.promise

		isConfigurationValid: ->
			@valid = false
			return @valid if not @conf.dockerCommand
			return @valid if not @conf.docker
			return @valid if not @conf.docker.connectionType
			return @valid if @conf.docker.connectionType == 'socket' and not @conf.docker.socket
			return @valid if @conf.docker.connectionType == 'tcpip' and (not @conf.docker.address or not @conf.docker.port )
			return @valid if @conf.docker.connectionType == 'tcpip' and @conf.docker.secure and not @conf.docker.certPath
			@valid = true
			return @valid

		detectCmd: (cmd) ->
			defer = $q.defer()
			process.exec("which #{cmd}").then (stdout, stderr) ->
				console.log "stderr: #{stderr}" if stderr
				if stdout
					path = stdout.replace "\n", ""
				defer.resolve(path) if stdout
				defer.reject()
			, (error, stderr) ->
				console.log 'exec error: ' + error
				console.log stderr
				defer.reject()
			return defer.promise

		load: ->
			q = $q.defer()
			@conf = {}
			@conf = storage.get "configuration"
			@conf = {} if not @conf
			@conf.docker = {} if not @conf.docker
			@isConfigurationValid()
			q.resolve @conf
			return q.promise

		save: ->
			defer = $q.defer()
			storage.set "configuration", @conf
			defer.resolve()
			console.log "Configuration saved"
			return defer.promise

	return new Service()

]
