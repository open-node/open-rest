_         = require 'underscore'
mysql     = require 'mysql'
dc        = decodeURIComponent

defaultPagination =
  maxResults: 10
  maxStartIndex: 10000
  maxResultsLimit: 5000

module.exports =
  dimensions: (Model, params) ->
    dimensions = params.dimensions
    # 如果 dimensions 定义了
    return unless dimensions
    # 但是不为字符串，直接返回错误
    throw Error('Dimensions must be a string') unless _.isString dimensions
    # 循环遍历维度设置
    dims = []
    for dim in dimensions.split(',')
      # 如果不在允许的范围内，则直接报错
      key = Model.stats.dimensions[dim]
      throw Error('Dimensions dont allowed') unless key
      dims.push "#{key} AS `#{dim}`"
    return dims

  group: (mets) ->
    return unless mets
    return unless _.isArray mets
    return unless mets.length
    _.map(mets, (x) -> x.split(' AS ')[1]).join(', ')

  metrics: (Model, params) ->
    metrics = params.metrics
    # 如果没有设置了指标
    throw Error('Metrics must be required') unless metrics
    # 如果设置了，但是不为字符串，直接返回错误
    throw Error('Metrics must be a string') unless _.isString metrics
    # 循环遍历所有的指标
    mets = []
    for met in metrics.split(',')
      # 如果指标不在允许的范围内，则直接报错
      key = Model.stats.metrics[met]
      throw Error('Metrics dont allowed') unless key
      mets.push "#{key} AS `#{met}`"
    return mets

  filters: (Model, params) ->
    filters = params.filters
    # 如果没有设置了过滤条件
    return unless filters
    # 如果设置但是不为字符串，直接返回错误
    throw Error('Filters must be a string') unless _.isString filters
    ands = []
    for _and in filters.split(';')
      ors = []
      for _or in _and.split(',')
        [k, v] = _or.split('==')
        col = Model.rawAttributes[k]
        key = col and "`#{k}`" or Model.stats.dimensions[k]
        throw Error('Filters set error') unless key
        ors.push "#{key} = #{mysql.escape dc v}"
      ands.push "(#{ors.join(' OR ')})"
    return unless ands.length
    return ands.join(' AND ')

  sort: (Model, params) ->
    {dimensions, metrics, sort}  = params
    return unless sort
    direction = 'ASC'

    if sort[0] is '-'
      direction = 'DESC'
      order = sort.substring(1)
    else
      order = sort

    allowSort = []
    for k in ['dimensions', 'metrics']
      if params[k] and _.isString params[k]
        allowSort = allowSort.concat params[k].split(',')
    return unless order in allowSort
    return "#{order} #{direction}"

  pageParams: (Model, params) ->
    pagination = Model.stats.pagination or defaultPagination
    startIndex = (+params.startIndex or 0)
    maxResults = (+params.maxResults or +pagination.maxResults)
    limit = Math.min(maxResults, pagination.maxResultsLimit)
    offset = Math.min(startIndex, pagination.maxStartIndex)
    return "#{offset}, #{limit}"
