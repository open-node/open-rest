/** 初始化 restapi 服务 */

var fs          = require('fs')
  , restify     = require('restify')
  , _           = require('underscore')
  , Router      = require('open-router')
  , helper      = require('./helper')
  , model       = require('./model')
  , utils       = require('./utils')
  , openrest    = require('../package');

/* 检查参数的正确性 */
var requiredCheck = function(opts) {

  /** 如果 opts 是个字符串, 则当作 appPath 来使用 */
  if (_.isString(opts)) opts = { appPath: opts };

  /** app路径检查 */
  if (!opts.appPath) throw Error('Lack appPath: absolute path of your app');

  /** 默认路径的处理，这里有一些路径上的约定 */
  _.each(['config', 'route', 'controller', 'model'], function(_path) {
    var pwd = opts[_path + 'Path'];
    if (pwd) {
      if (!_.isString(pwd)) {
        throw Error(_path + 'Path must be a string and be a existed path');
      }
      if (!fs.existsSync(pwd)) {
        throw Error(_path + 'Path must be a string and be a existed path');
      }
    } else {
      opts[_path + 'Path'] = opts.appPath + '/' + _path + 's';
    }
  });

  opts.config = utils.es6import(require(opts.configPath));

  /** 中间件路径的处理 */
  if (!opts.middleWarePath) {
    opts.middleWarePath = opts.appPath + '/middle-wares';
  }

  return opts;

};

/**
 * 根据传递进来的 opts 构建 restapi 服务
 * opts = {
 *   appPath: directory, // required 应用路径，绝对路径，这个非常重要，之后
 *   configPath: directory, // optional 配置项目路径，绝对路径，默认为 appPath + '/configs'
 *   routePath: directory, // optional 路由器配置路径，绝对路径
 *                       // 的控制器路径，模型路径都可以根绝这个路径生成
 *   controllerPath: directory // optional controllers 目录, 绝对路径,
 *                             // 默认为 appPath + '/controllers/'
 *   modelPath: directory // optional models 目录, 绝对路径,
 *                        // 默认为 appPath + '/models/'
 *   middleWarePath: directory // optional 用户自定义的中间件的路径，绝对路径
 * }
 *
 */
module.exports = function(opts) {

  var opts = requiredCheck(opts)
    , service = opts.config.service || openrest
    , server = restify.createServer({
        name: service.name,
        version: service.version
      })
    , middleWareIterator = function(middleWare) {
        server.use(function(req, res, next) {
          try {
            middleWare(req, res, next);
          } catch(error) {
            utils.logger.error(req.url, error);
            next(error);
          }
        });
      }
    , middleWares;

  /**
   * 初始化model，并且将models 传给initModels
   * 传进去的目的是为了后续通过 utils.model('modelName')来获取model
   */
  model.init(opts.config.db, opts.modelPath);

  /** 设置中间件 */
  server.use(restify.acceptParser(server.acceptable));
  server.use(restify.queryParser(opts.config.queryParser || null));
  server.use(restify.bodyParser(opts.config.bodyParser || null));
  server.use(function(req, res, next) {
    /**
     * 初始化 hooks
     * 因为后续要通过 req.hooks 来传递一些共用的变量
     */
    req.hooks = {};
    /** 强制处理字符集, 避免编码问题带来的隐患 */
    res.charSet(opts.config.charset || 'utf-8');
    next();
  });

  /** 自定义中间件 */
  if (fs.existsSync(opts.middleWarePath)) {
    middleWares = utils.es6import(require(opts.middleWarePath));
    _.each(middleWares, middleWareIterator);
  }

  /**
   * 路由初始化、控制器载入
   * 这样同样要处理es6 import的兼容问题
   */
  utils.es6import(require(opts.routePath))(new Router(
    server,
    utils.getModules(opts.controllerPath, ['coffee', 'js']),
    null,
    opts.config.route
  ));

  /** 监听错误，打印出来，方便调试 */
  server.on('uncaughtException', function(req, res, route, error) {
    utils.logger.error(route, error);
    if (!res.finished) res.send(500, 'Internal error');
  });

  server.listen(service.port or 8080, service.ip, function() {
    utils.logger.info('%s listening at %s', server.name, server.url);
  });

};
