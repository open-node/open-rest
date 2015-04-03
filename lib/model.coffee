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
# model的统计功能
# params的结构如下
# {
#   dimensions: 'dim1,dim2',
#   metrics: 'met1,met2',
#   filters: 'dim1==a;dim2!=b',
#   sort: '-met1',
#   startIndex: 0,
#   maxResults: 20
# }
###
model.statistics = statistics = (params, callback) ->
  Model = @
  {dimensions, metrics, filters, sort, startIndex, maxResults} = params
  return callback(Error('Forbidden statistics')) unless Model.statistics
  try
    dims = utils.stats.dimensions(Model, params)
    mets = utils.stats.metrics(Model, params)
    option =
      select: [].concat(dims or [], mets).join(',')
      where: utils.stats.filters(Model, params)
      table: Model.tableName
      group: utils.stats.group(dims)
      sort: utils.stats.sort(Model, params)
      limit: utils.stats.pageParams(Model, params)
  catch e
    return callback(e)
  sql = utils.getSql(option, 'SQL_CALC_FOUND_ROWS')
  type = Model.sequelize.QueryTypes.SELECT
  Model.sequelize.query(sql, {type}).done((error, results) ->
    return callback(error) if error
    sql = "SELECT FOUND_ROWS() AS total"
    Model.sequelize.query(sql, {type}).done((error, res) ->
      return callback(error) if error
      callback(null, [results, res[0].total])
    )
  )

###
# 返回列表查询的条件
###
model.findAllOpts = findAllOpts = (params, isAll = no) ->
  where = {}
  Model = @
  includes = modelInclude(params, Model.includes)
  _.each(Model.filterAttrs or Model.rawAttributes, (attr, name) ->
    utils.findOptFilter(params, name, where)
  )
  if Model.rawAttributes.isDelete and not params.showDelete
    where.isDelete = 'no'

  # 处理关联资源的过滤条件
  if includes
    _.each(includes, (x) ->
      includeWhere = {}
      _.each(x.model.filterAttrs or x.model.rawAttributes, (attr, name) ->
        utils.findOptFilter(params, "#{x.as}.#{name}", includeWhere, name)
      )
      if x.model.rawAttributes.isDelete and not params.showDelete
        includeWhere.isDelete = 'no'
      x.where = includeWhere if _.size(includeWhere)
    )


  ret =
    include: includes
    order: sort(params, Model.sort)
  ret.where = where if _.size(where)

  _.extend ret, Model.pageParams(params) unless isAll

  ret

# 处理关联包含
# 返回
# [Model1, Model2]
# 或者 undefined
model.modelInclude = modelInclude = (params, includes) ->
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
model.pageParams = pageParams = (params) ->
  pagination = @pagination
  startIndex = (+params.startIndex or 0)
  maxResults = (+params.maxResults or +pagination.maxResults)
  limit: Math.min(maxResults, pagination.maxResultsLimit)
  offset: Math.min(startIndex, pagination.maxStartIndex)

###
# 处理排序参数
###
model.sort = sort = (params, conf) ->
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
  opt.define.classMethods = {findAllOpts, pageParams, statistics}
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
