# 此模块提供标准的rest接口，如果某个接口是标准的实现
# 则直接调用即可，不用重复实现

_       = require 'underscore'
utils   = require '../../lib/utils'
errors  = require '../../lib/errors'

# 忽略list中的某些属性
# 因为有些属性对于某些接口需要隐藏
# 比如 medias/:media/campaigns 中项目的 mediaIds 就不能显示出来
# 否则媒体就能知道该项目还投放了那些媒体
listAttrFilter = (ls, allowAttrs) ->
  return ls unless allowAttrs
  _.map ls, (x) ->
    ret = {}
    ret[attr] = x[attr] for attr in allowAttrs
    ret

rest =

  # 获取资源列表的通用方法
  # _options 是否要去req.hooks上去options
  # allowAttrs 那些字段是被允许的
  list: (Model, opt = null, allowAttrs) ->
    (req, res, next) ->
      options = opt and req.hooks[opt] or utils.findAllOpts(req.params, Model)
      Model.findAndCountAll(options).success (result) ->
        res.header("X-Content-Record-Total", result.count)
        rows = listAttrFilter(result.rows, allowAttrs)
        if req.params.attrs
          rows = listAttrFilter(rows, req.params.attrs.split(','))
        res.send(200, rows)
        next()

  # 获取所有资源的通用方法
  # _options 是否要去req.hooks上去options
  # allowAttrs 那些字段是被允许的
  all: (Model, opt = null, allowAttrs) ->
    (req, res, next) ->
      options = (opt and req.hooks[opt]) or
        utils.findAllOpts(req.params, Model, yes)
      Model.findAll(options).success (ls) ->
        ls = listAttrFilter(ls, allowAttrs)
        if req.params.attrs
          ls = listAttrFilter(ls, req.params.attrs.split(','))
        res.send(200, ls)
        next()

  # 获取单个资源详情的方法
  detail: (hook, attachs = null, statusCode = 200) ->
    (req, res, next) ->
      model = req.hooks[hook]
      ret = if model.toJSON then model.toJSON() else model
      _.each(attachs, (v, k) -> ret[k] = req.hooks[v] or req[v]) if attachs
      res.send(statusCode, ret)
      next()

  beforeModify: (Model, hook, cols) ->
    (req, res, next) ->
      model = req.hooks[hook]
      cols = cols or Model.editableCols or Model.writableCols
      # 当设置了只有管理员才可以修改的字段，并且当前用户不是管理员
      # 则去掉那些只有管理员才能修改的字段
      if Model.onlyAdminCols and req.user.role isnt 'admin'
        cols = _.filter(cols, (x) -> x not in Model.onlyAdminCols)
      attr = utils.pickParams(req, cols)
      delete attr.id
      _.extend model, attr
      next()

  save: (Model, hook, cols) ->
    (req, res, next) ->
      model = req.hooks[hook]
      model.save().done((error, mod) ->
        err = errors.sequelizeIfError error
        next(err) if err
        res.send(200, mod)
        next()
      )

  # 修改某个资源描述的方法
  modify: (Model, hook, cols) ->
    [
      rest.beforeModify(Model, hook, cols)
      rest.save(Model, hook, cols)
    ]

  beforeAdd: (Model, cols, hook = Model.name) ->
    (req, res, next) ->
      attr = utils.pickParams(req, cols or Model.writableCols)
      attr.creatorId = req.user.id if Model.rawAttributes.creatorId

      # 存储数据
      _save = (model) ->
        model.save().done((error, mod) ->
          err = errors.sequelizeIfError error
          next(err) if err
          req.hooks[hook] = mod
          next()
        )

      # 如果没有设置唯一属性，或者没有开启回收站
      if not Model.unique or not Model.rawAttributes.isDelete
        return _save(Model.build(attr))

      # 如果设置了唯一属性，且开启了回收站功能
      # 则判断是否需要执行恢复操作
      where = {}
      where[x] = attr[x] for x in Model.unique
      Model.find({where}).done((error, model) ->
        next.ifError error
        if model
          _.extend model, attr
          model.isDelete = 'no'
        else
          model = Model.build(attr)
        _save(model)
      )

  # 根据资源描述添加资源到集合上的方法
  add: (Model, cols, hook = Model.name, attachs = null) ->
    [
      rest.beforeAdd(Model, cols, hook)
      rest.detail(hook, attachs, 201)
    ]

  # 删除某个资源
  remove: (hook) ->
    (req, res, next) ->
      model = req.hooks[hook]
      # 资源如果有isDelete 字段则修改isDelete 为yes即可
      (do ->
        if model.isDelete
          model.isDelete = 'yes'
          model.save()
        else
          model.destroy()
      ).success (mod) ->
        res.send(204)
        next()

module.exports = rest
