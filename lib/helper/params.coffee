_         = require 'underscore'
errors    = require '../errors'

params =

  # 忽略掉指定属性
  omit: (keys...) ->
    (req, res, next) ->
      return next() unless req.params?
      req.params = _.omit(req.params, keys)
      next()

  # 检测必要参数
  required: (keys) ->
    throw Error('params keys must be an array') unless _.isArray(keys)
    unless _.all(keys, (x) -> _.isString(x))
      throw Error('params keys every item must be a string')
    (req, res, next) ->
      missings = _.filter(keys, (key) -> not req.params[key])
      return next() unless missings.length
      next errors.missingParameter("Missing required params: #{missings}")

  # 将 params 的可以做一个简单的映射
  map: (dict) ->
    (req, res, next) ->
      for k, v of dict
        req.params[v] = req.params[k]
      next()

module.exports = params

