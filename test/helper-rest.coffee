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
      , Error, "First arguments `Model` must be an Sequelize Class.")
      done()

    it "opt check", (done) ->
      assert.throws(->
        rest.list(Model, ['hello'])
      , Error, "Second argument `opt` must be a String.")
      done()

    it "allowAttrs check is Array", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', 'world')
      , Error, "Third arguments `allowAttrs` must be an Array.")
      done()

    it "allowAttrs check string in Array", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', [null])
      , Error, "Third arguments `allowAttrs` each item in the array must be a string.")
      done()

    it "allowAttrs check string in Array and has defined", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', ['age'])
      , Error, "Third arguments `allowAttrs` has non-exists field: age.")
      done()

    it "hook check is string", (done) ->
      assert.throws(->
        rest.list(Model, 'hello', ['name'], ['niubi'])
      , Error, "The 4th argument `hook` must be a String.")
      done()

  describe 'rest.detail', ->
    it "hook check", (done) ->
      assert.throws(->
        rest.detail()
      , Error, "First arguments `hook` must be a String.")
      done()

    it "attachs check", (done) ->
      assert.throws(->
        rest.detail('user', 'hello')
      , Error, "Second argument `attachs` must be a Hash.")
      done()

    it "attrFilter check", (done) ->
      assert.throws(->
        rest.detail('user', {auth: 'auth'}, 'hello')
      , Error, "The 4th arguments `attrFilter` must be an Boolean.")
      done()

  describe 'rest.beforeModify', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.beforeModify()
      , Error, "First arguments `Model` must be an Sequelize Class.")
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.beforeModify(Model)
      , Error, "First arguments `hook` must be a String.")
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.beforeModify(Model, 'user', 'hello')
      , Error, "Third argument `cols` must be an Array.")
      done()

  describe 'rest.save', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.save()
      , Error, "First arguments `Model` must be an Sequelize Class.")
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.save(Model)
      , Error, "First arguments `hook` must be a String.")
      done()

  describe 'rest.modify', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.modify()
      , Error, "First arguments `Model` must be an Sequelize Class.")
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.modify(Model)
      , Error, "First arguments `hook` must be a String.")
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.modify(Model, 'user', 'hello')
      , Error, "Third argument `cols` must be an Array.")
      done()

  describe 'rest.beforeAdd', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.beforeAdd()
      , Error, "First arguments `Model` must be an Sequelize Class.")
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.beforeAdd(Model, 'user', 'hello')
      , Error, "Second argument `cols` must be an Array.")
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.beforeAdd(Model)
      , Error, "Third arguments `hook` must be a String.")
      done()

  describe 'rest.add', ->
    it "Model check", (done) ->
      assert.throws(->
        rest.add()
      , Error, "First arguments `Model` must be an Sequelize Class.")
      done()

    it "cols check", (done) ->
      assert.throws(->
        rest.add(Model, 'user', 'hello')
      , Error, "Second argument `cols` must be an Array.")
      done()

    it "hook check", (done) ->
      assert.throws(->
        rest.add(Model, null, ['hhh'])
      , Error, "Third arguments `hook` must be a String.")
      done()

    it "attachs check", (done) ->
      assert.throws(->
        rest.add(Model, null, 'user', 'hello')
      , Error, "The 4th argument `attachs` must be a Hash.")
      done()

  describe 'rest.remove', ->

    it "hook check", (done) ->
      assert.throws(->
        rest.remove()
      , Error, "First arguments `hook` must be a String.")
      done()
