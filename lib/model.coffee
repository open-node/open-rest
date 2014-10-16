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
# 初始化 models
# params
#   sequelize Sequelize 的实例
#   path models的存放路径
###
model.init = (opt, path) ->

  # 初始化db
  sequelize = new Sequelize(opt.name, opt.user, opt.pass, opt)
  sequelize.query "SET time_zone='+0:00'"

  for file in utils.readdir(path, 'coffee', ['index', 'base'])
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
