fs = require 'fs'
apm = require '../lib/apm-cli'

describe 'apm command line interface', ->
  beforeEach ->
    silenceOutput()
    spyOnToken()

  describe 'when no arguments are present', ->
    it 'prints a usage message', ->
      apm.run([])
      expect(console.log).not.toHaveBeenCalled()
      expect(console.error).toHaveBeenCalled()
      expect(console.error.argsForCall[0][0].length).toBeGreaterThan 0

  describe 'when the help flag is specified', ->
    it 'prints a usage message', ->
      apm.run(['-h'])
      expect(console.log).not.toHaveBeenCalled()
      expect(console.error).toHaveBeenCalled()
      expect(console.error.argsForCall[0][0].length).toBeGreaterThan 0

  describe 'when the version flag is specified', ->
    it 'prints the version', ->
      apm.run(['-v', '--no-color'])
      expect(console.error).not.toHaveBeenCalled()
      expect(console.log).toHaveBeenCalled()
      lines = console.log.argsForCall[0][0].split('\n')
      expect(lines[0]).toBe "apm  #{require('../package.json').version}"
      expect(lines[1]).toBe "npm  #{require('npm/package.json').version}"
      expect(lines[2]).toBe "node #{process.versions.node}"

  describe 'when an unrecognized command is specified', ->
    it 'prints an error message and exits', ->
      apm.run(['this-will-never-be-a-command'])
      expect(console.log).not.toHaveBeenCalled()
      expect(console.error).toHaveBeenCalled()
      expect(console.error.argsForCall[0][0].length).toBeGreaterThan 0
      expect(process.exit.mostRecentCall.args[0]).toBe 1
