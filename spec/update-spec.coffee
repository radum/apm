path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'
express = require 'express'
http = require 'http'
wrench = require 'wrench'
apm = require '../lib/apm-cli'

describe 'apm update', ->
  [moduleDirectory, server] = []

  beforeEach ->
    silenceOutput()
    spyOnToken()

    app = express()
    app.get '/node/v0.10.3/node-v0.10.3.tar.gz', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'node-v0.10.3.tar.gz')
    app.get '/node/v0.10.3/node.lib', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'node.lib')
    app.get '/node/v0.10.3/x64/node.lib', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'node_x64.lib')
    app.get '/tarball/test-module-1.0.0.tgz', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'test-module-1.0.0.tgz')
    server =  http.createServer(app)
    server.listen(3000)

    atomHome = temp.mkdirSync('apm-home-dir-')
    process.env.ATOM_HOME = atomHome
    process.env.ATOM_NODE_URL = "http://localhost:3000/node"
    process.env.ATOM_NODE_VERSION = 'v0.10.3'

    moduleDirectory = path.join(temp.mkdirSync('apm-test-module-'), 'test-module-with-dependencies')
    wrench.copyDirSyncRecursive(path.join(__dirname, 'fixtures', 'test-module-with-dependencies'), moduleDirectory)
    process.chdir(moduleDirectory)

  afterEach ->
    server.close()

  it 'uninstalls any packages not referenced in the package.json and installs any missing packages', ->
    removedPath = path.join(moduleDirectory, 'node_modules', 'will-be-removed')
    fs.makeTreeSync(removedPath)

    callback = jasmine.createSpy('callback')
    apm.run(['update'], callback)

    waitsFor 'waiting for command to complete', ->
      callback.callCount > 0

    runs ->
      expect(fs.existsSync(removedPath)).toBeFalsy()
      expect(fs.existsSync(path.join(moduleDirectory, 'node_modules', 'test-module', 'index.js'))).toBeTruthy()
      expect(fs.existsSync(path.join(moduleDirectory, 'node_modules', 'test-module', 'package.json'))).toBeTruthy()
