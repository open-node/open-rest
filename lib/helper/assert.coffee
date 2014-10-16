_       = require 'underscore'
errors  = require '../errors'

# checker 所有的方法都可能随时会调用next error
# checker 的思路就是判断，如果发现不一致的数据，就返回异常

module.exports =
  # 检测某字段是否与指定的值是否相同，如果不同则报错
  equal: (field, value, _obj, msg) ->
    (req, res, next) ->
      return next(Error req.i18n.t msg) if req.hooks[_obj][field] isnt value
      next()

  # 检测某个字段是否在某个数组里包含
  inArray: (key1, obj1, key2, obj2, msg) ->
    (req, res, next) ->
      value1 = req.hooks[obj1][key1]
      value2 = req.hooks[obj2][key2]
      value2 = value2.split(',') if _.isString value2
      value2 = _.map(value2, (x) -> +x) if _.isNumber value1
      return next(Error req.i18n.t msg) unless value1 in value2
      next()

  # 检测是否存在
  exists: (hook, msg = null, allowNull = no, deleteKey) ->
    (req, res, next) ->
      model = req.hooks[hook]
      msg = msg or req.i18n.t msg
      unless model
        if allowNull
          delete req.params[deleteKey]
          return next()
        return next(errors.notFound msg)
      return next(errors.notFound msg) if model.isDelete is 'yes'
      next()

