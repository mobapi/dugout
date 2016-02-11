coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
del = require 'del'
expect = require 'gulp-expect-file'
less = require 'gulp-less'
gettext = require 'gulp-angular-gettext'
gulp = require 'gulp'
gutil = require 'gulp-util'
html2js = require 'gulp-ng-html2js'
merge = require 'merge2'
minifyhtml = require 'gulp-minify-html'
NodeWebkitBuilder = require 'nw-builder'
packagejson = require './package.json'
vinylpaths = require 'vinyl-paths'

nw =
	version: '0.12.3'
	cacheDir: '.nwcache'
	platforms: [ 'linux64', 'osx64', 'win64' ]

directories =
	source: 'src'
	dist: 'www'
	build: 'build'
	libs: 'bower_components'

files =
	app:
		index: "#{directories.source}/index.html"
		coffee: "#{directories.source}/coffee/**/*.coffee"
		templates: "#{directories.source}/templates/**/*.html"
		css: [
			"#{directories.source}/css/**/*.css"
		]
		fonts: [
			"#{directories.source}/fonts/**/*"
		]
		images: [
			"#{directories.source}/images/**/*"
		]
		po: [
			"#{directories.source}/po/**/*.po"
		]
	libs:
		js: [
			"#{directories.libs}/jquery/dist/jquery.js"
			"#{directories.libs}/angular/angular.js"
			"#{directories.libs}/angular-animate/angular-animate.js"
			"#{directories.libs}/angular-bootstrap/ui-bootstrap-tpls.js"
			"#{directories.libs}/angular-gettext/dist/angular-gettext.js"
			"#{directories.libs}/angular-hotkeys/build/hotkeys.js"
			"#{directories.libs}/angular-i18n/angular-locale_fr.js"
			"#{directories.libs}/angular-local-storage/dist/angular-local-storage.js"
			"#{directories.libs}/angular-sanitize/angular-sanitize.js"
			"#{directories.libs}/angular-ui-router/release/angular-ui-router.js"
			"#{directories.libs}/angular-ui-switch/angular-ui-switch.js"
			"#{directories.libs}/angularjs-toaster/toaster.js"
			"#{directories.libs}/async/dist/async.js"
			"#{directories.libs}/bootstrap/dist/js/bootstrap.js"
			"#{directories.libs}/lodash/lodash.js"
			"#{directories.libs}/metisMenu/dist/metisMenu.js"
			"#{directories.libs}/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.js"
			"#{directories.libs}/moment/moment.js"
			"#{directories.libs}/moment/locale/fr.js"
			"#{directories.libs}/ng-scrollbars/src/scrollbars.js"
			"#{directories.libs}/ng-prettyjson/dist/ng-prettyjson.min.js"
			"#{directories.libs}/sprintf/src/sprintf.js"
			"#{directories.libs}/sprintf/src/angular-sprintf.js"
		]
		css: [
			"#{directories.libs}/angular-ui-switch/angular-ui-switch.css"
			"#{directories.libs}/angularjs-toaster/toaster.css"
			"#{directories.libs}/bootstrap/dist/css/bootstrap.css"
			"#{directories.libs}/font-awesome/css/font-awesome.css"
			"#{directories.libs}/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.css"
			"#{directories.libs}/metisMenu/dist/metisMenu.css"
			"#{directories.libs}/ng-prettyjson/dist/ng-prettyjson.min.css"
			"#{directories.libs}/startbootstrap-sb-admin-2/dist/css/sb-admin-2.css"
		]
		fonts: [
			"#{directories.libs}/bootstrap/fonts/glyphicons-halflings-regular.ttf"
			"#{directories.libs}/bootstrap/fonts/glyphicons-halflings-regular.woff"
			"#{directories.libs}/bootstrap/fonts/glyphicons-halflings-regular.woff2"
			"#{directories.libs}/font-awesome/fonts/fontawesome-webfont.ttf"
			"#{directories.libs}/font-awesome/fonts/fontawesome-webfont.woff"
			"#{directories.libs}/font-awesome/fonts/fontawesome-webfont.woff2"
		]


# Libs
gulp.task 'libs', [ 'libs_js', 'libs_css', 'libs_fonts' ]

gulp.task 'libs_js', ->
	return gulp.src files.libs.js
		.pipe expect
			errorOnFailure: true
		, files.libs.js
		.on 'error', ->
			process.exit -1
		.pipe concat("libs.js")
		.pipe gulp.dest("#{directories.dist}/js/")

gulp.task 'libs_css', ->
	return gulp.src files.libs.css
		.pipe expect
			errorOnFailure: true
		, files.libs.css
		.on 'error', ->
			process.exit -1
		.pipe concat("libs.css")
		.pipe gulp.dest("#{directories.dist}/css/")

gulp.task 'libs_fonts', ->
	return gulp.src files.libs.fonts
		.pipe expect
			errorOnFailure: true
		, files.libs.fonts
		.on 'error', ->
			process.exit -1
		.pipe gulp.dest("#{directories.dist}/fonts/")


# App
gulp.task 'app', [ 'app_index', 'app_js', 'app_css', 'app_images', 'app_fonts' ], ->
	return gulp.src "package.json"
		.pipe gulp.dest("#{directories.dist}")

gulp.task 'app_index', ->
	return gulp.src files.app.index
		.pipe gulp.dest("#{directories.dist}/")

gulp.task 'app_js', [ 'app_coffee', 'app_templates', 'app_translations' ], ->
	return gulp.src [ "#{directories.dist}/js/coffee.js", "#{directories.dist}/js/templates.js", "#{directories.dist}/js/translations.js" ]
		.pipe vinylpaths(del)
		.pipe concat('app.js')
		.pipe gulp.dest("#{directories.dist}/js/")

gulp.task 'app_coffee', ->
	return gulp.src files.app.coffee
		.pipe coffee({ bare: true }).on('error', gutil.log)
		.pipe concat("coffee.js")
		.pipe gulp.dest("#{directories.dist}/js/")

gulp.task 'app_templates', ->
	return gulp.src files.app.templates
		.pipe minifyhtml(
			empty: true
			spare: true
			quotes: true
    	)
		.pipe html2js(
			moduleName: 'dugout'
			declareModule: false
		)
		.pipe concat("templates.js")
		.pipe gulp.dest("#{directories.dist}/js/")

gulp.task 'app_translations', ->
	return gulp.src files.app.po
		.pipe gettext.compile({
			# options to pass to angular-gettext-tools...
			format: 'javascript'
		})
		.pipe concat('translations.js')
		.pipe gulp.dest("#{directories.dist}/js/")

gulp.task 'app_css', ->
	return gulp.src files.app.css
		.pipe concat("app.css")
		.pipe gulp.dest("#{directories.dist}/css/")

gulp.task 'app_images', ->
	return gulp
		.src files.app.images
		.pipe gulp.dest("#{directories.dist}/images/")

gulp.task 'app_fonts', ->
	return gulp
		.src files.app.fonts
		.pipe gulp.dest("#{directories.dist}/fonts/")

gulp.task 'app_build', ->
	nw_builder_files = [ "node_modules/**/*", "!node_modules/**/node_modules/**/*" ]
	nw_builder_files.push 
	for d of packagejson.devDependencies
		nw_builder_files.push "!node_modules/#{d}/**/*"
	for i in [ '!node_modules/nw-gyp/**',
		'!node_modules/**/*.bin',
		'!node_modules/**/*.c',
		'!node_modules/**/*.h',
		'!node_modules/**/Makefile',
		'!node_modules/**/*.h',
		'!**/test*/**',
		'!**/doc/**',
		'!**/example*/**',
		'!**/demo*/**',
		'!**/bin/**',
		'!**/build/**',
		'!**/.*/**',
		"#{directories.dist}/**/*" ]
		nw_builder_files.push i
	# console.dir nw_builder_files
	options =
		version: nw.version
		buildDir: directories.build
		cacheDir: nw.cacheDir
		files: nw_builder_files
		platforms: nw.platforms
		buildType: ->
			return @appVersion
		macIcns: "icon.icns"
		winIco: "icon.ico" if 'win64' in nw.platforms
	nodeWebkit = new NodeWebkitBuilder options
	nodeWebkit.on 'log', console.log
	return nodeWebkit.build()

gulp.task 'build', [ 'app_build' ], ->
	for platform in nw.platforms
		((platform) ->
			olddirectory = "#{directories.build}/#{packagejson.version}/#{platform}/"
			newdirectory = "#{directories.build}/#{packagejson.version}/#{packagejson.name}-#{platform}-v#{packagejson.version}/"
			gulp.src "#{olddirectory}/**/*"
				.pipe gulp.dest newdirectory
				.on 'end', ->
					gulp.src "project.sample.json"
						.pipe gulp.dest newdirectory
						.on 'end', ->
							del olddirectory
		)(platform)


gulp.task 'pot', ->
	return gulp
		.src [ files.app.index, "#{directories.dist}/js/app.js", files.app.templates ]
		.pipe gettext.extract "translations.pot"
		.pipe gulp.dest "#{directories.source}/po/"


gulp.task 'watch', () ->
	gulp.watch files.app.index, [ 'app_index' ]
	gulp.watch files.app.templates, [ 'app_js' ]
	gulp.watch files.app.coffee, [ 'app_js' ]
	gulp.watch files.app.po, [ 'app_js' ]
	gulp.watch files.app.css, [ 'app_css' ]

gulp.task 'clean', (callback) ->
	del [ directories.dist, directories.build ], callback

gulp.task 'default', [ 'libs', 'app' ]
