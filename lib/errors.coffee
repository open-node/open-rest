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

NormalError = (error) ->
  restify.RestError.call this, {
    restCode: 'NormalError'
    statusCode: 500
    message: error.errors
    constructorOpt: NormalError
  }
  this.name = 'NormalError'

util.inherits ArgumentError, restify.RestError
util.inherits NormalError, restify.RestError

module.exports = errors =
  # 资源不存在错误，有以下几种情况需要返回此错误
  # 1. 资源确实不存在，无法查找到
  # 2. 资源存在，但是 isDelete 为 yes
  # 3. 资源存在，但是操作者没有权限，做这个的目的是为了防止恶意的资源探测
  notFound: (msg = 'ResourceNotExists', field) ->
    return new restify.ResourceNotFoundError msg unless field
    error =
      errors: [
        message: msg
        path: field
      ]
    new ArgumentError(error)

  # 用户没有权限
  notAllowed: (msg = 'NotAllowedError') ->
    new restify.NotAuthorizedError msg

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
  sequelizeIfError: (error, field) ->
    return null unless error
    if field
      error =
        errors: [
          message: error.message
          path: field
        ]
    new ArgumentError(error)

  # 通用错误处理
  ifError: (error, field) ->
    return null unless error
    return errors.sequelizeIfError(error, field) if field
    return error

  # 普通错误
  normalError: (msg, values...) ->
    new NormalError
      errors: [
        message: msg
        values: values
      ]
