restify = require 'restify'
util    = require 'util'

ArgumentError = (error) ->
  restify.RestError.call this, {
    restCode: 'ArgumentError'
    statusCode: 422
    message: error.errors
    constructorOpt: ArgumentError
  }
  this.name = 'ArgumentError'

util.inherits ArgumentError, restify.RestError

module.exports =
  # 资源不存在错误，有以下几种情况需要返回此错误
  # 1. 资源确实不存在，无法查找到
  # 2. 资源存在，但是 isDelete 为 yes
  # 3. 资源存在，但是操作者没有权限，做这个的目的是为了防止恶意的资源探测
  notFound: (msg = 'ResourceNotExists') ->
    new restify.ResourceNotFoundError msg

  # 用户为授权错误，有以下几种情况需要返回此错误
  # 1. 请求未携带 access_token
  # 2. 根据 access_token 无法从 open 获取用户
  # 3. 用户不存在于该系统
  notAuth: new restify.NotAuthorizedError 'NotAuthorizedError'

  # 请求参数错误
  invalidArgument: new restify.InvalidArgumentError 'InvalidArgumentError'

  # 丢失参数错误
  missingParameter: new restify.MissingParameterError 'MissingParameterError'

  # SequelizeIfError
  sequelizeIfError: (error) ->
    return null unless error
    new ArgumentError(error)
