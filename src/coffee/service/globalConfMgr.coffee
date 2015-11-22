app
.service 'globalConfMgr',
['$q', 'localStorageService',
($q, storage) ->

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

		setLanguage: (language) ->
			@conf.language = language
			gettextCatalog.setCurrentLanguage language
			@save()

		removeLanguage: ->
			storage.remove 'language'

		isConfigurationValid: ->
			@valid = false
			return @valid if not @conf.docker
			return @valid if not @conf.docker.connectionType
			return @valid if @conf.docker.connectionType == 'socket' and not @conf.docker.socket
			return @valid if @conf.docker.connectionType == 'tcpip' and (not @conf.docker.address or not @conf.docker.port)
			return @valid if @conf.docker.connectionType == 'tcpip' and @conf.docker.secure and not @conf.docker.certPath
			@valid = true
			return @valid

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
