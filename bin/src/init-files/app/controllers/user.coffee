rest    = require 'open-rest'
utils   = require '../lib/utils'
helper  = require './helper'

User = rest.model('user')

module.exports =
  list: [
    helper.rest.list(User)
  ]
  modify: [
    helper.getter(User, 'user')
    helper.assert.exists('user')
    helper.rest.modify(User, 'user')
  ]
  del:[
    helper.getter(User, 'user')
    helper.assert.exists('user')
    helper.rest.remove('user')
  ]
  detail: [
    helper.getter(User, 'user')
    helper.checker.exists('user')
    helper.rest.detail('user')
  ]
  add: [
    helper.rest.add(User, ['name', 'email', 'status', 'role'])
  ]
