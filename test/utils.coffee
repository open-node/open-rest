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

