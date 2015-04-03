# 此模块提供标准的rest接口，如果某个接口是标准的实现
# 则直接调用即可，不用重复实现

_       = require 'underscore'
async   = require 'async'
utils   = require '../../lib/utils'
errors  = require '../../lib/errors'

rest =

  # 输出
  detail: (hook, attachs = null, statusCode = 200) ->
    (req, res, next) ->
      ret = _.map(req.hooks[hook], (model) ->
        json = if model.toJSON then model.toJSON() else model
        _.each(attachs, (v, k) -> json[k] = req.hooks[v] or req[v]) if attachs
        json
      )
      ret = ret[0] if not _.isArray(req.body) and ret.length is 1
      res.send statusCode, ret
      next()

  # 批量验证
  validate: (Model, cols, hook) ->
    (req, res, next) ->
      body = _.isArray(req.body) and req.body or [req.body]
      origParams = _.clone(req.params)
      handler = (params, callback) ->
        req.params = _.extend params, origParams
        attr = utils.pickParams(req, cols or Model.writableCols)
        attr.creatorId = req.user.id if Model.rawAttributes.creatorId
        attr.clientIp = utils.clientIp(req) if Model.rawAttributes.clientIp

        # 构建实例
        model = Model.build(attr)
        model.validate().done((error, results) ->
          callback(error or results, model)
        )
      async.map(body, handler, (error, results) ->
        err = errors.sequelizeIfError error
        return next(err) if err
        req.hooks[hook] = results
        next()
      )

  # 报错
  save: (hook, Model) ->
    (req, res, next) ->
      ls = _.map(req.hooks[hook], (x) -> x.toJSON())
      Model.bulkCreate(ls).done((error, results) ->
        err = errors.sequelizeIfError error
        return next(err) if err
        req.hooks[hook] = results
        next()
      )


  # 批量添加
  add: (Model, cols, hook = "#{Model.name}s", attachs = null) ->
    [
      rest.validate(Model, cols, hook)
      rest.save(hook, Model)
      rest.detail(hook, attachs, 201)
    ]

module.exports = rest

