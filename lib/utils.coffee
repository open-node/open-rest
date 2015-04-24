fs        = require 'fs'
path      = require 'path'
_         = require 'underscore'
Sequelize = require 'sequelize'
model     = require './model'
stats     = require './stats'

utils =
  ###
  # 将字符串转换为数字
  ###
  intval: (value, mode = 10) ->
    parseInt(value, mode) or 0

  # 根据设置的路径，获取对象
  getModules: (_path) ->
    modules = {}
    for file in utils.readdir(_path, ['coffee', 'js'])
      moduleName = utils.file2Module file
      modules[moduleName] = require "#{_path}/#{file}"

    modules

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

  # 真实的连接请求端ip
  remoteIp: (req) ->
    req.connection && req.connection.remoteAddress or
    req.socket && req.socket.remoteAddress or
    (
      req.connection && req.connection.socket &&
      req.connection.socket.remoteAddress
    )

  ###
  # 获取客户端真实ip地址
  ###
  clientIp: (req) ->
    (
      req.headers['x-forwarded-for'] or
      utils.remoteIp(req)
    ).split(',')[0]

  ###
  # 获取可信任的真实ip
  ###
  realIp: (req, proxyIps = []) ->
    remoteIp = utils.remoteIp(req)
    return remoteIp unless remoteIp in proxyIps
    return req.headers['x-real-ip'] or remoteIp

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

  # 统计相关的功能
  stats: stats

  # 根据条件拼接sql语句
  getSql: (option, keyword = '') ->
    [
      "SELECT #{keyword} #{option.select} FROM #{option.table}"
      "WHERE #{option.where}" if option.where
      "GROUP BY #{option.group}" if option.group
      "ORDER BY #{option.sort}" if option.sort
      "LIMIT #{option.limit}" if option.limit
    ].join(' ')

  # findOptFilter 的处理
  findOptFilter: (params, name, where, col = name) ->
    # 处理 where 的等于
    if _.isString params[name]
      value = params[name].trim()
      # 特殊处理null值
      value = null if value is '.null.'
      where[col] = {} unless where[col]
      where[col].$eq = value
    if _.isNumber params[name]
      where[col] = {} unless where[col]
      where[col].$eq = params[name]
    # 处理where in
    if _.isString params["#{name}s"]
      where[col] = {} unless where[col]
      where[col].$in = params["#{name}s"].trim().split(',')
    # 处理where not in
    if _.isString params["#{name}s!"]
      where[col] = {} unless where[col]
      where[col].$not = params["#{name}s!"].trim().split(',')
    # 处理不等于的判断
    if _.isString params["#{name}!"]
      value = params["#{name}!"].trim()
      # 特殊处理null值
      value = null if value is '.null.'
      where[col] = {} unless where[col]
      where[col].$ne = value
    # 处理like
    if _.isString params["#{name}_like"]
      value = params["#{name}_like"].trim().replace(/\*/g, '%')
      # 特殊处理null值
      where[col] = {} unless where[col]
      where[col].$like = value
    # 处理notLike
    if _.isString params["#{name}_notLike"]
      value = params["#{name}_notLike"].trim().replace(/\*/g, '%')
      # 特殊处理null值
      where[col] = {} unless where[col]
      where[col].$notLike = value
    # 处理大于，小于, 大于等于，小于等于的判断
    _.each(['gt', 'gte', 'lt', 'lte'], (x) ->
      if _.isString params["#{name}_#{x}"]
        value = params["#{name}_#{x}"].trim()
        where[col] = {} unless where[col]
        where[col]["$#{x}"] = value
    )

module.exports = utils
