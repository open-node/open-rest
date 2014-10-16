fs        = require 'fs'
path      = require 'path'
_         = require 'underscore'
Sequelize = require 'sequelize'

# 用来记录所有的系统model，用来给model提供使用
models = {}

utils =
  ###
  # 将字符串转换为数字
  ###
  intval: (value, mode = 10) ->
    parseInt(value, mode) or 0

  ###
  # 返回列表查询的条件
  ###
  findAllOpts: (params, Model, isAll = no) ->
    where = {}
    ins = []
    ands = [where]
    _.each(Model.filterAttrs or Model.rawAttributes, (attr, name) ->
      # 处理 where 的等于
      if _.isString params[name]
        value = params[name].trim()
        # 特殊处理null值
        value = null if value is '.null.'
        where[name] = {} unless where[name]
        where[name].eq = value
      # 处理where in
      if params["#{name}s"]
        _in = {}
        _in[name] = in: params["#{name}s"].split(',')
        ins.push _in
      # 处理不等于的判断
      if _.isString params["#{name}!"]
        value = params["#{name}!"].trim()
        # 特殊处理null值
        value = null if value is '.null.'
        where[name] = {} unless where[name]
        where[name].ne = value
      # 处理大于，小于, 大于等于，小于等于的判断
      _.each(['gt', 'gte', 'lt', 'lte'], (x) ->
        if _.isString params["#{name}_#{x}"]
          value = params["#{name}_#{x}"].trim()
          where[name] = {} unless where[name]
          where[name][x] = value
      )
    )
    ands.push(Sequelize.or.apply Sequelize, ins) if ins.length
    if Model.rawAttributes.isDelete and not params.showDelete
      where.isDelete = 'no'

    ret =
      where: Sequelize.and.apply Sequelize, ands
      include: utils.modelInclude(params, Model.includes)
      order: utils.sort(params, Model.sort)

    _.extend ret, utils.pageParams(params, Model.pagination) unless isAll

    ret

  # 处理关联包含
  # 返回
  # [Model1, Model2]
  # 或者 undefined
  modelInclude: (params, includes) ->
    return unless includes
    return unless params.includes
    ret = _.filter(params.includes.split(','), (x) -> includes[x])
    return if ret.length is 0
    _.map(ret, (x) ->
      model: utils.model(includes[x])
      as: x
    )

  ###
  # 处理分页参数
  # 返回 {
  #   limit: xxx,
  #   offset: xxx
  # }
  ###
  pageParams: (params, pagination) ->
    startIndex = (+params.startIndex or 0)
    maxResults = (+params.maxResults or +pagination.maxResults)
    limit: Math.min(maxResults, pagination.maxResultsLimit)
    offset: Math.min(startIndex, pagination.maxStartIndex)

  ###
  # 处理排序参数
  ###
  sort: (params, conf) ->
    order = conf.default
    direction = 'ASC'

    return null if not params.sort

    if params.sort[0] is '-'
      direction = 'DESC'
      order = params.sort.substring(1)
    else
      order = params.sort

    # 如果请求的排序方式不允许，则返回null
    return null if not conf.allow or order not in conf.allow

    [[order, direction]]

  ###
  # 从 req 中提取所需的参数
  ###
  pickParams: (req, cols) ->
    attr = {}
    _.each cols, (col) ->
      attr[col] = req.params[col] if req.params[col]?
      attr[col] = null if req.params[col] is ''

    attr

  ###
  # 判断给定ip是否是白名单里的ip地址
  ###
  isPrivateIp: (ip, whiteList) ->
    ip in whiteList

  ###
  # 获取客户端真实ip地址
  ###
  clientIp: (req) ->
    (
      req.headers['x-forwarded-for'] or
      req.connection.remoteAddress or
      req.socket.remoteAddress or
      req.connection.socket.remoteAddress
    ).split(',')[0]

  # writelog
  writeLog: (file, msg) ->
    _path = path.dirname(file)
    fs.mkdirSync(_path) unless fs.existsSync(_path)
    fs.appendFileSync file, "#{msg}\n"

  # 读取录下的所有模块，之后返回数组
  # 对象的key是模块的名称，值是模块本身
  # params
  #   dir 要加载的目录
  #   exts 要加载的模块文件后缀，多个可以是数组, 默认为 coffee
  #   excludes 要排除的文件, 默认排除 index
  readdir: (dir, exts = 'coffee', excludes = 'index') ->
    exts = [exts] if _.isString exts
    excludes = [excludes] if _.isString excludes
    _.chain(fs.readdirSync(dir))
      .map((x) -> x.split('.'))
      .filter((x) -> x[1] in exts and x[0] not in excludes)
      .map((x) -> x[0])
      .value()

  # 文件名称到moduleName的转换
  # example, twe cases
  # case1. filename => filename
  # case2. file-name => fileName
  file2Module: (file) ->
    file.replace /(\-\w)/g, (m) -> m[1].toUpperCase()

  # 获取id，从 params 或者 hooks 中
  getId: (req, _id, _obj) ->
    obj = if _obj then req.hooks[_obj] else req.params
    utils.intval obj[_id]

  ucwords: (value) ->
    return value unless _.isString(value)
    "#{value[0].toUpperCase()}#{value.substring(1)}"

module.exports = utils
