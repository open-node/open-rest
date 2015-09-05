assert      = require 'assert'
utils       = require '../lib/utils'

describe 'Utils', ->

  describe '#file2Module', ->
    it "filename return filename", (done) ->
      assert.equal 'filename', utils.file2Module('filename')
      done()

    it "file-name return fileName", (done) ->
      assert.equal 'fileName', utils.file2Module('file-name')
      done()

  describe "#str2arr", ->
    it "normal", (done) ->
      assert.deepEqual ['a', 'b', 'c'], utils.str2arr('a b c', ' ')
      done()

    it "comma split, dont need cut", (done) ->
      assert.deepEqual ['a', 'b', 'c'], utils.str2arr('a,b,c', ',')
      done()

    it "comma split, take 2", (done) ->
      assert.deepEqual ['a', 'b'], utils.str2arr('a,b,c', ',', 2)
      done()

    it "empty str split, take 2", (done) ->
      assert.deepEqual ['a', 'b'], utils.str2arr('abc', '', 2)
      done()
