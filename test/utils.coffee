assert      = require 'assert'
utils       = require '../lib/utils'

describe 'Utils', ->

  describe '#intval', ->
    it "noraml", (done) ->
      assert.equal 2, utils.intval(2)
      done()

    it "string 2", (done) ->
      assert.equal 2, utils.intval('2')
      done()

    it "string 2aa", (done) ->
      assert.equal 2, utils.intval('2aa')
      done()

    it "8 mode 10", (done) ->
      assert.equal 8, utils.intval('10', 8)
      done()

    it "string aaa, result is number 0", (done) ->
      assert.equal 0, utils.intval('aaa')
      done()

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

    it 'empty str', (done) ->
      assert.deepEqual undefined, utils.str2arr('', ',', 2)
      done()

  describe '#searchOpt', ->
    Model =
      name: 'user'
      searchCols:
        name:
          op: 'LIKE'
          match: ['%{1}%']
        email:
          op: 'LIKE'
          match: ['%{1}%']
        id:
          op: '='
          match: ['{1}']

    it "normal", (done) ->
      except = [
        ["((`user`.`name` LIKE '%a%'))"]
        ["((`user`.`email` LIKE '%a%'))"]
        ["((`user`.`id` = 'a'))"]
      ]
      real = utils.searchOpt(Model, '', 'a')
      assert.deepEqual except, real
      done()

    it "mutil keyword", (done) ->
      except = [
        [
          '((`user`.`name` LIKE \'%a%\'))'
          '((`user`.`name` LIKE \'%b%\'))'
        ]
        [
          '((`user`.`email` LIKE \'%a%\'))'
          '((`user`.`email` LIKE \'%b%\'))'
        ]
        [
          '((`user`.`id` = \'a\'))'
          '((`user`.`id` = \'b\'))'
        ]
      ]
      real = utils.searchOpt(Model, '', 'a b')
      assert.deepEqual except, real
      done()

    it "mutil match, single keyword", (done) ->
      Model =
        name: 'user'
        searchCols:
          name:
            op: 'LIKE'
            match: ['{1}', '%,{1}', '{1},%', '%,{1},%']
          email:
            op: 'LIKE'
            match: ['%{1}%']
          id:
            op: '='
            match: ['{1}']
      except = [
        [
          '((`user`.`name` LIKE \'a\') OR (`user`.`name` LIKE \'%,a\') OR (`user`.`name` LIKE \'a,%\') OR (`user`.`name` LIKE \'%,a,%\'))'
          '((`user`.`name` LIKE \'b\') OR (`user`.`name` LIKE \'%,b\') OR (`user`.`name` LIKE \'b,%\') OR (`user`.`name` LIKE \'%,b,%\'))'
        ]
        [
          '((`user`.`email` LIKE \'%a%\'))'
          '((`user`.`email` LIKE \'%b%\'))'
        ]
        [
          '((`user`.`id` = \'a\'))'
          '((`user`.`id` = \'b\'))'
        ]
      ]

      real = utils.searchOpt(Model, '', 'a b')
      assert.deepEqual except, real
      done()

    it "container single quote", (done) ->
      Model =
        name: 'user'
        searchCols:
          name:
            op: 'LIKE'
            match: ['%{1}%']
      except = [
        ["((`user`.`name` LIKE '%a\\\'%'))"]
      ]
      real = utils.searchOpt(Model, '', "a'")
      assert.deepEqual except, real
      done()

  describe '#mergeSearchOrs', ->
    it 'single searchOpt result', (done) ->
      Model =
        name: 'user'
        searchCols:
          name:
            op: 'LIKE'
            match: ['%{1}%']
      except = "((((`user`.`name` LIKE '%a%'))))"
      real = utils.mergeSearchOrs [utils.searchOpt(Model, '', "a")]
      assert.deepEqual except, real
      done()

    it 'single searchOpt, mutil keyword result', (done) ->
      Model =
        name: 'user'
        searchCols:
          name:
            op: 'LIKE'
            match: ['%{1}%']
      except = "((((`user`.`name` LIKE '%a%'))) AND (((`user`.`name` LIKE '%b%'))))"
      real = utils.mergeSearchOrs [utils.searchOpt(Model, '', "a b")]
      assert.deepEqual except, real
      done()

    it 'mutil searchOpt, single keyword result', (done) ->
      Model1 =
        name: 'user'
        searchCols:
          name:
            op: 'LIKE'
            match: ['%{1}%']
      Model2 =
        name: 'book'
        searchCols:
          name:
            op: 'LIKE'
            match: ['%{1}%']
      except = "((((`user`.`name` LIKE '%a%')) OR ((`book`.`name` LIKE '%a%'))))"
      real = utils.mergeSearchOrs([
        utils.searchOpt(Model1, '', "a")
        utils.searchOpt(Model2, '', "a")
      ])
      assert.deepEqual except, real
      done()

    it 'mutil searchOpt, mutil keyword result', (done) ->
      Model1 =
        name: 'user'
        searchCols:
          name:
            op: 'LIKE'
            match: ['%{1}%']
      Model2 =
        name: 'book'
        searchCols:
          name:
            op: 'LIKE'
            match: ['%{1}%']
      except = "((((`user`.`name` LIKE '%a%')) OR ((`book`.`name` LIKE '%a%'))) AND (((`user`.`name` LIKE '%b%')) OR ((`book`.`name` LIKE '%b%'))))"
      real = utils.mergeSearchOrs([
        utils.searchOpt(Model1, '', "a b")
        utils.searchOpt(Model2, '', "a b")
      ])
      assert.deepEqual except, real
      done()
