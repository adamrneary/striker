global.assert = require 'assert'
global.request = require 'request'
spawn = require('child_process').spawn
server = {}
port = 5000

describe 'test server', ->
    it 'run server', (done)->
        server = spawn 'node', ['run.js']
        server.stdout.on 'data', (data)->
            data = data.toString()
            process.stdout.write data
            if data is 'server start on port 5000\n'
                done()
        server.stderr.on 'data', (data)->
            process.stdout.write data.toString()

    it "test localhost:#{port}", (done)->
        request.get "http://localhost:#{port}", (err,res,body)->
            assert body
            done()


    it 'test localhost:3000/styleguide', (done)->
        request.get "http://localhost:#{port}/styleguide", (err,res,body)->
            assert body
            done()

    it 'test localhost:3000/mocha', (done)->
        request.get "http://localhost:#{port}/mocha", (err,res,body)->
            assert body
            done()

    after (done)->
        server.kill()
        done()
