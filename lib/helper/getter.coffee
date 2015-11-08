utils = require '../../lib/utils'
model = require '../model'

# 获取某个资源的 helper 方法
# params 有四个
#   Model required 资源的模型
#   hook required 资源获取回来以后要挂载的钩子名称
#   _id optional 资源的id名称，比如`id` or `userId` default `id`
#   _obj optional 资源id所在的对象，默认会从req.params获取，如果指定了
#         字符串，则读取 req.hooks[_obj]
module.exports = (Model, hook, _id = 'id', _obj = null) ->
  (req, res, next) ->
    obj = if _obj then req.hooks[_obj] else req.params
    id = utils.intval obj[_id]
    include = model.modelInclude(req.params, Model.includes)
    utils.callback(Model.find({where: {id}, include}), (error, model) ->
      return next(error) if error
      req.hooks[hook] = model
      next()
    )
