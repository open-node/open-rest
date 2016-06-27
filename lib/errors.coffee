restify = require 'restify'
util    = require 'util'

ArgumentError = (error) ->
  restify.RestError.call this, {
    restCode: 'ArgumentError'
    statusCode: 422
    message: error.errors or error.message
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
  notFound: (msg = 'Resource not found.', field) ->
    return new restify.ResourceNotFoundError msg unless field
    error =
      errors: [
        message: msg
        path: field
      ]
    new ArgumentError(error)

  # 用户没有权限
  notAllowed: (msg = 'Not allowed error.') ->
    new restify.ForbiddenError msg

  # 用户为授权错误，有以下几种情况需要返回此错误
  # 1. 请求未携带 access_token
  # 2. 根据 access_token 无法从 open 获取用户
  # 3. 用户不存在于该系统
  notAuth: (msg = 'Not authorized error.') ->
    new restify.NotAuthorizedError msg

  # 请求参数错误
  invalidArgument: (msg = 'Invalid argument error.', values) ->
    error = new restify.InvalidArgumentError msg
    error.body.value = values if values and values.length
    error

  # 丢失参数错误
  missingParameter: (msg = 'Missing parameter error.', missings) ->
    new restify.MissingParameterError msg, missings

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

  # 标准错误，直接返回 Error, 只是可以增加 value 字段
  error: (msg, values...) ->
    error = new Error(msg)
    error.value = values
    error
