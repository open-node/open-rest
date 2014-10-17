_         = require 'underscore'
model     = require './model'
utils     = require './utils'

# 路由器初始化
# params
#   server object restify.createServer()
#   controller ./controller
#   defaults 默认控制器方法
module.exports = (server, ctls, defaults) ->

  register = (verb, routePath, ctlAct) ->

    [ctl, action] = ctlAct.split('#')

    # 如果定义的对应的控制器，也有对应的方法则使用该方法
    actions = ctls[ctl][action] if ctls[ctl] and ctls[ctl][action]

    # 反之则使用默认的方法来处理
    actions = defaults[action](model ctl) unless actions

    # 如果都没有则抛出异常
    throw Error "控制器缺少route指定的方法" unless actions

    # 如果actions是数组，则把数组弄成一维的
    actions = _.flatten actions if _.isArray actions

    # 强制把actions处理成一个数组
    actions = [actions] unless _.isArray actions

    # 将每一个action都用try catch处理
    actions = _.map(actions, (action) ->
      (req, res, next) ->
        try
          action(req, res, next)
        catch e
          console.error e
          console.error e.stack
          next(e)
    )
    server[verb].apply server, [routePath].concat actions

  router = {}
  _.each(['get', 'post', 'put', 'patch', 'del'], (verb) ->
    router[verb] = (routePath, ctlAct) ->
      register verb, routePath, ctlAct
  )

  ###
  controller 为可选参数，如果不填写则控制器名称直接就是 res ，方法为 list,add
  如果设置了controller 则控制器为 controller，方法为 #{res}s, add{Res}
  ###
  router.collection = (res, routePath, controller) ->
    unless routePath
      if controller
        routePath = "/#{controller}s/:#{controller}Id/#{res}s"
      else
        routePath = "/#{res}s"
    if controller
      register 'get', routePath, "#{controller}##{res}s"
      register 'post', routePath, "#{controller}#add#{utils.ucwords(res)}"
    else
      register 'get', routePath, "#{res}#list"
      register 'post', routePath, "#{res}#add"

  router.model = (res, routePath) ->
    routePath = "/#{res}s/:id" unless routePath
    register 'get', routePath, "#{res}#detail"
    register 'put', routePath, "#{res}#modify"
    register 'patch', routePath, "#{res}#modify"
    register 'del', routePath, "#{res}#remove"

  router.resource = (res, routePath) ->
    routePath = "/#{res}s" unless routePath
    router.collection res, routePath
    router.model res, "#{routePath}/:id"

  return router
