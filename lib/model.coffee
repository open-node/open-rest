# model of open-rest
_         = require 'underscore'
utils     = require './utils'
Sequelize = require 'sequelize'

# 存放 models 的定义
Models = {}

###
# 根据model名称获取model
###
model = (name = null) ->
  return Models unless name
  Models[name]

###
# 返回列表查询的条件
###
findAllOpts = (params, isAll = no) ->
  where = {}
  ins = []
  ands = [where]
  Model = @
  _.each(Model.filterAttrs or Model.rawAttributes, (attr, name) ->
    # 处理 where 的等于
    if _.isString params[name]
      value = params[name].trim()
      # 特殊处理null值
      value = null if value is '.null.'
      where[name] = {} unless where[name]
      where[name].eq = value
    if _.isNumber params[name]
      where[name] = {} unless where[name]
      where[name].eq = params[name]
    # 处理where in
    if params["#{name}s"]
      _in = {}
      _in[name] = in: params["#{name}s"].split(',')
      ins.push _in
    # 处理where not in
    if params["#{name}s!"]
      where[name] = {} unless where[name]
      where[name].not = params["#{name}s!"].split(',')
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
    include: modelInclude(params, Model.includes)
    order: sort(params, Model.sort)

  _.extend ret, Model.pageParams(params) unless isAll

  ret

# 处理关联包含
# 返回
# [Model1, Model2]
# 或者 undefined
modelInclude = (params, includes) ->
  return unless includes
  return unless params.includes
  ret = _.filter(params.includes.split(','), (x) -> includes[x])
  return if ret.length is 0
  _.map(ret, (x) ->
    model: model(includes[x])
    as: x
  )

###
# 处理分页参数
# 返回 {
#   limit: xxx,
#   offset: xxx
# }
###
pageParams = (params) ->
  pagination = @pagination
  startIndex = (+params.startIndex or 0)
  maxResults = (+params.maxResults or +pagination.maxResults)
  limit: Math.min(maxResults, pagination.maxResultsLimit)
  offset: Math.min(startIndex, pagination.maxStartIndex)

###
# 处理排序参数
###
sort = (params, conf) ->
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
# 初始化 models
# params
#   sequelize Sequelize 的实例
#   path models的存放路径
###
model.init = (opt, path) ->

  # 初始化db
  opt.define = {} unless opt.define
  opt.define.classMethods = {findAllOpts, pageParams}
  sequelize = new Sequelize(opt.name, opt.user, opt.pass, opt)
  sequelize.query "SET time_zone='+0:00'"

  for file in utils.readdir(path, ['coffee', 'js'], ['index', 'base'])
    moduleName = utils.file2Module file
    Models[moduleName] = require("#{path}/#{file}")(sequelize)

  # model 之间关系的定义
  # 未来代码模块化更好，每个文件尽可能独立
  # 这里按照资源的紧密程度来分别设定资源的结合关系
  # 否则所有的结合关系都写在一起会很乱
  for file in utils.readdir("#{path}/associations")
    require("#{path}/associations/#{file}")(Models)

  # 处理 model 定义的 includes
  _.each Models, (Model, name) ->
    if _.isArray Model.includes
      includes = {}
      _.each Model.includes, (include) -> includes[include] = include
      Model.includes = includes
    Models[name] = Model

module.exports = model
