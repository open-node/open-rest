/** model of open-rest */
var _             = require('lodash')
  , utils         = require('./utils')
  , Sequelize     = require('sequelize');

/** 存放 models 的定义, 方便随时取出 */
var Models = {};

/**
 * 根据model名称获取model
 */
var model = function(name) {
  if (!name) return Models;
  return Models[name];
};

var defineModel = function(sequelize, path) {
  var models = utils.getModules(path, ['coffee', 'js'], ['index', 'base']);

  _.each(models, function(v, k) {
    Models[k] = Models[k] || v(sequelize);
  });
};

/**
 * model 之间关系的定义
 * 未来代码模块化更好，每个文件尽可能独立
 * 这里按照资源的紧密程度来分别设定资源的结合关系
 * 否则所有的结合关系都写在一起会很乱
 */
var activeRelations = function(path) {
  var relations = utils.getModules(path + '/associations', ['coffee', 'js']);

  _.each(relations, function(v) {
    v(Models);
  });
};

/** 处理 model 定义的 includes, includes 会在查询的时候用到 */
var activeIncludes = function() {
  _.each(Models, function(Model, name) {
    var includes;
    if (!Model.includes) return;
    if (_.isArray(Model.includes)) {
      includes = {};
      _.each(Model.includes, function(include) {
        includes[include] = include;
      });
      Model.includes = includes;
    }
    _.each(Model.includes, function(v, k) {
      var modelName, required;
      if (!_.isArray(v)) {
        v = [v, true]
      }
      modelName = v[0];
      required = v[1];
      Model.includes[k] = {
        model: Models[modelName],
        as: k,
        required: required
      };
    });
  });
};

/** 处理 model 定义的 searchCols */
var searchCols = function() {
  _.each(Models, function(Model, name) {
    if (!Model.searchCols) return;
    _.each(Model.searchCols, function(v, k) {
      if (_.isString(v.match)) v.match = [v.match];
    });
  });
};

/**
 * 判断如果是 development 模式下 sync 表结构
 * 同时满足两个条件 development 模式, process.argv 包含 table-sync
 */
var tableSync = function() {
  if (process.env.NODE_ENV !== 'development') return;
  if (!_.includes(process.argv, 'table-sync')) return;
  _.each(Models, function(Model) {
    Model
      .sync()
      .then(utils.logger.info.bind(utils.logger, "Synced"))
      .catch(utils.logger.error);
  });
};

/**
 * 初始化 models
 * params
 *   sequelize Sequelize 的实例
 *   path models的存放路径
 */
model.init = function(opt, path) {

  /** 初始化db */
  var sequelize = new Sequelize(opt.name, opt.user, opt.pass, opt);

  /** 强制设置为 0 时区，避免服务器时区差异带来的不一致问题 */
  sequelize.query("SET time_zone='+0:00'").catch(utils.logger.error);

  /** 定义Model */
  defineModel(sequelize, path);

  /** 激活Model之间的关系 */
  activeRelations(path);

  /** 处理资源之间的包含，所属关系 */
  activeIncludes();

  /** 处理资源的搜索条件 */
  searchCols();

  /** 同步表结构到数据库中 */
  tableSync();

};

module.exports = model;
