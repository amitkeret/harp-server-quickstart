gulp = require 'gulp'
harp = require 'harp'
coffee = require 'gulp-coffeeify'
browserSync = do require 'browser-sync'
  .create
proc = require 'execa'
pretty = require 'gulp-jsbeautifier'
clean = require 'gulp-clean'

coffeeTask = (env)->
  gulp.src './src/main.coffee'
    .pipe coffee options: debug: (if env is 'dev' then yes else no)
    .pipe gulp.dest './src'
gulp.task 'coffee-dev', -> coffeeTask 'dev'
gulp.task 'coffee-dist', -> coffeeTask 'dist'

gulp.task 'serve', ->
  harp.server '.',
    port: 9000
  , ->
    browserSync.init
      proxy: 'localhost:9000'
      open: false

gulp.task 'reload', -> do browserSync.reload
gulp.task 'watch', ->
  gulp.watch [
    './index.jade'
    './src/**/*',
    '!./src/main.js'
    './templates/**/*'
  ], ['coffee-dev', 'reload']

gulp.task 'default', ['coffee-dev', 'serve', 'watch']

gulp.task 'copy', ->
  gulp.src ['./index.jade', './_layout.jade']
    .pipe gulp.dest './temp'
  gulp.src './src/**/*'
    .pipe gulp.dest './temp/src'

gulp.task 'compile', ['coffee-dist', 'copy'], (done)->
  proc.shell 'harp compile ./temp ./www'

gulp.task 'build', ['compile'], ->
  gulp.src './www/**/*'
    .pipe pretty indent_size: 2
    .pipe gulp.dest './www'
  gulp.src './temp'
    .pipe do clean
