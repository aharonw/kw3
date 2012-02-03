fs              = require 'fs'
{ print }       = require 'util'
{ spawn, exec } = require 'child_process'

build = (watch, callback) ->
  if typeof watch is 'function'
    callback = watch
    watch = false
  options = ['-b', '-c', '-o', 'lib', 'src']
  options.unshift '-w' if watch

  coffee = spawn 'coffee', options
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()
  coffee.on 'exit', (status) -> callback?() if status is 0

serve = ->
  node = spawn 'node', [__dirname + '/lib/app.js']
  node.stdout.on 'data', (data) -> print data.toString()
  node.stderr.on 'data', (data) -> print data.toString()

task 'build', 'Compile coffeescript source files', ->
  build()

task 'watch', 'Recompile coffeescript source files when modified', ->
  build true

task 'serve', 'Run the Keep Winging server locally', ->
  serve()
