# 此模块提供标准的rest接口，如果某个接口是标准的实现
# 则直接调用即可，不用重复实现

_       = require 'underscore'
utils   = require '../utils'
errors  = require '../errors'

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

  # 单一资源的统计功能
  statistics: (Model, options = null, hook) ->
    (req, res, next) ->
      where = options and req.hooks[options].where or ''
      Model.statistics(req.params, where, (error, ret) ->
        return next(error) if error
        [data, total] = ret
        res.header("X-Content-Record-Total", total)
        hook and (req.hooks[hook] = data) or res.send(200, data)
        next()
      )

  # 获取资源列表的通用方法
  # _options 是否要去req.hooks上去options
  # allowAttrs 那些字段是被允许的
  # hook 默认为空，如果指定了hook，则数据不直接输出而是先挂在 hook上
  list: (Model, opt = null, allowAttrs, hook = null) ->
    # 统计符合条件的条目数
    getTotal = (opt, ignoreTotal, callback) ->
      return callback() if ignoreTotal
      utils.callback(Model.count(opt), callback)

    (req, res, next) ->
      options = opt and req.hooks[opt] or Model.findAllOpts(req.params)
      countOpt = {}
      countOpt.where = options.where if options.where
      countOpt.include = options.include if options.include
      # 是否忽略总条目数，这样就可以不需要count了。在某些时候可以
      # 提高查询速度
      ignoreTotal = req.params._ignoreTotal is 'yes'
      getTotal(countOpt, ignoreTotal, (error, count) ->
        return next(error) if error
        if (ignoreTotal or count)
          Model.findAll(options).then((result) ->
            res.header("X-Content-Record-Total", count) unless ignoreTotal
            ls = listAttrFilter(result, allowAttrs)
            ls = listAttrFilter(ls, req.params.attrs.split(',')) if req.params.attrs
            hook and (req.hooks[hook] = ls) or res.send(200, ls)
            next()
          ).catch(next)
        else
          ls = []
          res.header("X-Content-Record-Total", 0) unless ignoreTotal
          hook and (req.hooks[hook] = ls) or res.send(200, ls)
          next()
      )

  # 获取所有资源的通用方法
  # _options 是否要去req.hooks上去options
  # allowAttrs 那些字段是被允许的
  # hook 默认为空，如果指定了hook，则数据不直接输出而是先挂在 hook上
  all: (Model, opt = null, allowAttrs, hook = null) ->
    (req, res, next) ->
      options = (opt and req.hooks[opt]) or
        Model.findAllOpts(req.params, yes)
      utils.callback(Model.findAll(options), (error, ls) ->
        return next(error) if error
        ls = listAttrFilter(ls, allowAttrs)
        ls = listAttrFilter(ls, req.params.attrs.split(',')) if req.params.attrs
        hook and (req.hooks[hook] = ls) or res.send(200, ls)
        next()
      )

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
      model.save().then((mod) ->
        res.send(200, mod)
        next()
      ).catch((error) ->
        return next(errors.sequelizeIfError error)
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
      attr.clientIp = utils.clientIp(req) if Model.rawAttributes.clientIp

      # 存储数据
      _save = (model) ->
        model.save().then((mod) ->
          req.hooks[hook] = mod
          next()
        ).catch((error) ->
          return next errors.sequelizeIfError error
        )
      # 如果没有设置唯一属性，或者没有开启回收站
      if not Model.unique or not Model.rawAttributes.isDelete
        return _save(Model.build(attr))

      # 如果设置了唯一属性，且开启了回收站功能
      # 则判断是否需要执行恢复操作
      where = {}
      where[x] = attr[x] for x in Model.unique
      Model.findOne({where}).then((model) ->
        if model
          _.extend model, attr
          model.isDelete = 'no'
        else
          model = Model.build(attr)
        _save(model)
      ).catch(next)

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
      ).then((mod) ->
        res.send(204)
        next()
      ).catch(next)

module.exports = rest
