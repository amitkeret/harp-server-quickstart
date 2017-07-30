gulp = require 'gulp'
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

gulp.task 'watch', ->
  gulp.watch './*.jade', browserSync.reload
  gulp.watch './src/**/*', browserSync.reload

gulp.task 'default', ['serve', 'watch']
