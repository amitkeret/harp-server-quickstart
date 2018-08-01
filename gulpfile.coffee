gulp = require 'gulp'

#
# build main.js with browserify
#
browserify = require 'browserify'
source = require 'vinyl-source-stream'
coffeeify = require 'coffeeify'
gulp.task 'js:main', ->
  b = browserify
    entries: './src/main.coffee'
    debug: yes
    transform: [coffeeify]
    extensions: ['.coffee']
  b = do b.bundle
  b.pipe source 'main.js'
    .pipe gulp.dest './src'

#
# optional: concat static assets
###
resolve = require 'resolve'
concat = require 'gulp-concat'
gulp.task 'js:assets', ->
  gulp.src [
      resolve.sync 'jquery'
      # put other statis assets here
    ]
  .pipe concat 'assets.js'
  .pipe do uglify
  .pipe gulp.dest './src'

###
# run harp server
#
harp = require 'harp'
browserSync = do require 'browser-sync'
  .create
gulp.task 'serve', ->
  harp.server '.',
    port: 9000
  , ->
    browserSync.init
      proxy: 'localhost:9000'
      open: false

#
# watch task with browserSync
#
gulp.task 'reload', -> do browserSync.reload
gulp.task 'watch', ->
  gulp.watch [
    './index.jade'
    './src/**/*',
    '!./src/*.js'
  ], gulp.series 'js:main', 'reload'

#
# development task
#
gulp.task 'default', gulp.series 'js:main', gulp.parallel 'serve', 'watch'

#
# prepare temporary folder for harp.compile()
#
gulp.task 'copy', ->
  gulp.src [
      './*.jade'
      './src/**/*.*(js|styl|scss|jade)'
    ], base: '.'
  .pipe gulp.dest './temp'

#
# harp.compile()
#
proc = require 'execa'
gulp.task 'compile', ->
  proc.shell 'harp compile ./temp ./www'

#
# minify the browserify JS
#
uglify = require 'gulp-uglify-es'
  .default
gulp.task 'uglify', ->
  gulp.src './www/src/*.js'
    .pipe do uglify
    .pipe gulp.dest './www/src'

#
# optional: for readability
#
pretty = require 'gulp-jsbeautifier'
gulp.task 'beautify', ->
  gulp.src './www/**/*.*(css|html)'
    .pipe pretty indent_size: 2
    .pipe gulp.dest './www'

#
# remove temporary folder
#
clean = require 'gulp-clean'
gulp.task 'clean', ->
  gulp.src [
      './temp'
      './www/src/*(styl|jade)'
    ]
  .pipe do clean

#
# build (compile) task
#
gulp.task 'compile:pre', gulp.series 'js:main', 'copy'
gulp.task 'compile:post', gulp.series gulp.parallel('uglify', 'beautify'), 'clean'
gulp.task 'build', gulp.series 'compile:pre', 'compile', 'compile:post'
