app
.service 'dockerUtil',
['$q', 'globalConfMgr',
($q, globalConfMgr) ->

	class Service

		init: ->
			@globalConf = globalConfMgr.conf
			@buildDockerObj()

		buildDockerObj: ->
			return if not @globalConf
			Docker = require 'dockerode'
			Docker.prototype.getContainerByName = (name, cb) ->
				@listContainers
					all: true
				, (error, containers) =>
					if error
						return cb error
					matched = _.filter containers, (container) ->
						found = false
						for n in container.Names
							if n.indexOf(name) > -1
								found = true
								break
						return found
					if matched.length
						container = @getContainer matched[0].Id
					else
						container = null
					return cb null, container
			if @globalConf.docker.connectionType == 'socket'
				@docker = new Docker
					socketPath: "#{@globalConf.docker.socket}"
			else if @globalConf.docker.connectionType == 'tcpip'
				options =
					host: @globalConf.docker.address
					port: @globalConf.docker.port
				if @globalConf.docker.secure
					fs = require 'fs'
					options.ca = fs.readFileSync "#{@globalConf.docker.certPath}/ca.pem"
					options.cert = fs.readFileSync "#{@globalConf.docker.certPath}/cert.pem"
					options.key = fs.readFileSync "#{@globalConf.docker.certPath}/key.pem"
				@docker = new Docker options

		ping: ->
			d = $q.defer()
			return d.reject() if not @globalConf
			@docker.ping (error, data) ->
				if error
					return d.reject error
				d.resolve()
			return d.promise


	return new Service()

]
