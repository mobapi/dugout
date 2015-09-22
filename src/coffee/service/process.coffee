app
.service 'process',
['$q',
($q) ->

	class Process

		exec: (cmd, env) ->
			console.debug "exec: #{cmd}"
			q = $q.defer()
			require('child_process').exec "#{cmd}",
				env: env
			, (error, stdout, stderr) ->
				q.reject(error, stderr) if error
				q.resolve stdout, stderr
			return q.promise

		spawn: (cmd, args, env) ->
			console.debug "spawn: #{cmd} #{args.join(' ')}"
			q = $q.defer()
			p = require('child_process').spawn cmd, args,
				env: env
			p.on 'exit', (code) ->
				return q.reject code if code
				# console.log "#{cmd} #{args[0]}: exit #{code}"
				return q.resolve()
			p.stdout.on 'data', (data) ->
				q.notify
					stdout: data
			p.stderr.on 'data', (data) ->
				q.notify
					stderr: data
			return q.promise

	return new Process()

]
