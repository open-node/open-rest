# 初始化 restapi 服务

restify     = require 'restify'
_           = require 'underscore'
Router      = require './lib/router'
helper      = require "./lib/helper"
model       = require "./lib/model"
utils       = require "./lib/utils"
openrest    = require "../package"

# 根据设置的路径，获取对象
getModules = (_path) ->
  modules = {}
  for file in utils.readdir(_path, ['coffee', 'js'])
    moduleName = utils.file2Module file
    modules[moduleName] = require "#{_path}/#{file}"

  modules

# 检查参数的正确性
requiredCheck = (opts) ->

  # app路径检查
  unless opts.appPath
    throw Error 'Lack appPath: absolute path of your app'

  # todo list 以后补上

# 根据传递进来的 opts 构建 restapi 服务
# opts = {
#   config: Object, // 配置项目
#   routerInit: function(r) {}, // required 路由器初始化的函数，用户自定义
#   appPath: directory, // required 应用路径，绝对路径，这个非常重要，之后
#                       // 的控制器路径，模型路径都可以根绝这个路径生成
#   controllerPath: directory // optional controllers 目录, 绝对路径,
#                             // 默认为 appPath + '/controllers/'
#   modelPath: directory // optional models 目录, 绝对路径,
#                        // 默认为 appPath + '/models/'
#   middleWares: array(), // optional 用户自定义的中间件
# }
#
module.exports = (opts) ->

  # required check
  requiredCheck(opts)

  # 初始化数据库查询
  sequelize   = utils.initDB config.db

  # 初始化model，并且将models 传给initModels
  # 传进去的目的是为了后续通过 utils.model('modelName')来获取model
  model.init(sequelize, opts.modelPath or "#{opts.appPath}/models")

  # 创建web服务
  service = opts.config.service or openrest
  server = restify.createServer
    name: service.name
    version: service.version

  # 设置中间件
  server.use restify.acceptParser(server.acceptable)
  server.use restify.queryParser()
  server.use restify.bodyParser()
  server.use (req, res, next) ->
    # 初始化 hooks
    req.hooks = {}
    # 强制处理字符集
    res.charSet opts.config.charset or 'utf-8'
    next()

  # 自定义中间件
  # 需要自定义一些中间件，请写在这里
  if _.isArray opts.middleWare
    server.use(middleWare) for middleWare in opts.middleWares

  # 路由初始化、控制器载入
  opts.routerInit new Router(
    server
    getModules(opts.controllerPath or "#{opts.appPath}/controllers")
    helper.defaults
  )

  # 监听错误，打印出来，方便调试
  server.on 'uncaughtException', (req, res, route, error) ->
    console.error new Date
    console.error route
    console.error error
    res.send(500, 'Internal error')

  # 设置监听
  server.listen config.service.port or 8080, ->
    console.log '%s listening at %s', server.name, server.url
