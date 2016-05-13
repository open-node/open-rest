# 此模块提供标准的rest接口，如果某个接口是标准的实现
# 则直接调用即可，不用重复实现

_       = require 'underscore'
utils   = require '../utils'
errors  = require '../errors'

# 忽略list中的某些属性
# 因为有些属性对于某些接口需要隐藏
# 比如 medias/:media/campaigns 中项目的 mediaIds 就不能显示出来
# 否则媒体就能知道该项目还投放了那些媒体
itemAttrFilter = (allowAttrs) ->
  (x) ->
    ret = {}
    ret[attr] = x[attr] for attr in allowAttrs
    ret

listAttrFilter = (ls, allowAttrs) ->
  return ls unless allowAttrs
  _.map ls, itemAttrFilter(allowAttrs)

rest =

  # 单一资源的统计功能
  # conf 是额外的附加的Model上的指标和纬度的设置
  # 下面有 metrics 或 dimensions
  # 提供这个功能的目的是有时候Model统计是指定和维度的定义并非静态的
  # 而是跟着数据变动的,此时这个功能就变得十分有用
  statistics: (Model, options = null, hook, _conf) ->
    (req, res, next) ->
      conf = null
      conf = req.hooks[_conf] if _conf
      where = options and req.hooks[options].where or ''
      Model.statistics(req.params, where, conf, (error, ret) ->
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
            unless hook
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
      options = (opt and req.hooks[opt]) or Model.findAllOpts(req.params, yes)
      ignoreTotal = req.params._ignoreTotal is 'yes'
      utils.callback(Model.findAll(options), (error, ls) ->
        return next(error) if error
        ls = listAttrFilter(ls, allowAttrs)
        unless hook
          ls = listAttrFilter(ls, req.params.attrs.split(',')) if req.params.attrs
        res.header("X-Content-Record-Total", ls.length) unless ignoreTotal
        hook and (req.hooks[hook] = ls) or res.send(200, ls)
        next()
      )

  # 获取单个资源详情的方法
  detail: (hook, attachs = null, statusCode = 200) ->
    (req, res, next) ->
      model = req.hooks[hook]
      ret = if model.toJSON then model.toJSON() else model
      _.each(attachs, (v, k) -> ret[k] = req.hooks[v] or req[v]) if attachs
      if req.params.attrs
        attrs = req.params.attrs.split(',')
        if _.isArray(ret)
          ret = listAttrFilter(ret, attrs)
        else
          ret = itemAttrFilter(attrs)(ret)

      res.send(statusCode, ret)
      next()

  beforeModify: (Model, hook, cols) ->
    (req, res, next) ->
      model = req.hooks[hook]
      cols = cols or Model.editableCols or Model.writableCols
      attr = utils.pickParams(req, cols, Model)
      delete attr.id
      _.each(attr, (v, k) ->
        return if model[k] is v
        model[k] = v
      )
      next()

  save: (Model, hook) ->
    (req, res, next) ->
      model = req.hooks[hook]
      # 如果没有变化，则不需要保存，也不需要记录日志
      unless model.changed()
        req._resourceNotChanged = yes
        res.header("X-Content-Resource-Status", 'Unchanged')
        res.send(200, model)
        return next()
      model.save().then((mod) ->
        res.send(200, mod)
        next()
      ).catch((error) ->
        return next(errors.sequelizeIfError error)
      )

  # 修改某个资源描述的方法
  modify: (Model, hook, cols) ->
    (req, res, next) ->
      rest.beforeModify(Model, hook, cols)(req, res, (error) ->
        return next(error) if error
        rest.save(Model, hook)(req, res, next)
      )

  beforeAdd: (Model, cols, hook = Model.name) ->
    (req, res, next) ->
      attr = utils.pickParams(req, cols or Model.writableCols, Model)
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
          if model.isDelete is 'yes'
            _.extend model, attr
            model.isDelete = 'no'
          else
            next(errors.ifError(Error('Resource exists.'), Model.unique[0]))
        else
          model = Model.build(attr)
        _save(model)
      ).catch(next)

  # 根据资源描述添加资源到集合上的方法
  add: (Model, cols, hook = Model.name, attachs = null) ->
    (req, res, next) ->
      rest.beforeAdd(Model, cols, hook)(req, res, (error) ->
        return next(error) if error
        rest.detail(hook, attachs, 201)(req, res, next)
      )

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
