assert      = require 'assert'
rest        = require '../lib/helper/rest'

Sequelize   = require 'sequelize'
sequelize   = new Sequelize()

Model = sequelize.define('user', {
  id:
    type: Sequelize.INTEGER.UNSIGNED
    primaryKey: yes
    autoIncrement: yes
  name:
    type: Sequelize.STRING
    allowNull: no
})

describe 'helper.rest', ->
  describe 'list', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.list()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `Model` must be an Sequelize Class."
      )
      done()

    it "opt check", (done) ->
      assert.throws(->
        rest.list(Model, ['hello'])
      , (err) ->
        (err instanceof Error) and err.message is "Second argument `opt` must be a String."
      )
      done()

    it "allowAttrs check is Array", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', 'world')
      , (err) ->
        (err instanceof Error) and err.message is "Third argument `allowAttrs` must be an Array."
      )
      done()

    it "allowAttrs check string in Array", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', [null])
      , (err) ->
        (err instanceof Error) and err.message is "Third argument `allowAttrs` each item in the array must be a string."
      )
      done()

    it "allowAttrs check string in Array and has defined", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', ['age'])
      , (err) ->
        (err instanceof Error) and err.message is "Third argument `allowAttrs` has non-exists field: age."
      )
      done()

    it "hook check is string", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', ['name'], ['niubi'])
      , (err) ->
        (err instanceof Error) and err.message is "The 4th argument `hook` must be a String."
      )
      done()

  describe 'rest.detail', ->
    it "hook check", (done) ->
      assert.throws(->
        rest.detail()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `hook` must be a String."
      )
      done()

    it "attachs check", (done) ->
      assert.throws(->
        rest.detail('user', 'hello')
      , (err) ->
        (err instanceof Error) and err.message is "Second argument `attachs` must be a Hash."
      )
      done()

    it "statusCode check", (done) ->
      assert.throws(->
        rest.detail('user', null, '201')
      , (err) ->
        (err instanceof Error) and (err.message is "Third argument `statusCode` must be a Number.")
      )
      done()

    it "attrFilter check", (done) ->
      assert.throws(->
        rest.detail('user', {auth: 'auth'}, 201, 'hello')
      , (err) ->
        (err instanceof Error) and (err.message is "The 4th argument `attrFilter` must be an Boolean.")
      )
      done()

  describe 'rest.beforeModify', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.beforeModify()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `Model` must be an Sequelize Class."
      )
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.beforeModify(Model)
      , (err) ->
        (err instanceof Error) and err.message is "Second argument `hook` must be a String."
      )
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.beforeModify(Model, 'user', 'hello')
      , (err) ->
        (err instanceof Error) and err.message is "Third argument `cols` must be an Array."
      )
      done()

  describe 'rest.save', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.save()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `Model` must be an Sequelize Class."
      )
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.save(Model)
      , (err) ->
        (err instanceof Error) and err.message is "Second argument `hook` must be a String."
      )
      done()

  describe 'rest.modify', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.modify()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `Model` must be an Sequelize Class."
      )
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.modify(Model, ['user'])
      , (err) ->
        (err instanceof Error) and err.message is "Second argument `hook` must be a String."
      )
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.modify(Model, 'user', 'hello')
      , (err) ->
        (err instanceof Error) and err.message is "Third argument `cols` must be an Array."
      )
      done()

  describe 'rest.beforeAdd', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.beforeAdd()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `Model` must be an Sequelize Class."
      )
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.beforeAdd(Model, 'user', 'hello')
      , (err) ->
        (err instanceof Error) and err.message is "Second argument `cols` must be an Array."
      )
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.beforeAdd(Model, null, ['hello'])
      , (err) ->
        (err instanceof Error) and err.message is "Third argument `hook` must be a String."
      )
      done()

  describe 'rest.add', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.add()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `Model` must be an Sequelize Class."
      )
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.add(Model, 'user', 'hello')
      , (err) ->
        (err instanceof Error) and err.message is "Second argument `cols` must be an Array."
      )
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.add(Model, null, ['hhh'])
      , (err) ->
        (err instanceof Error) and err.message is "Third argument `hook` must be a String."
      )
      done()

    it "attachs check", (done) ->
      assert.throws(->
        rest.add(Model, null, 'user', 'hello')
      , (err) ->
        (err instanceof Error) and (err.message is "The 4th argument `attachs` must be a Hash.")
      )
      done()

  describe 'rest.remove', ->

    it "hook check", (done) ->
      assert.throws(->
        rest.remove()
      , (err) ->
        (err instanceof Error) and err.message is "First argument `hook` must be a String."
      )
      done()
