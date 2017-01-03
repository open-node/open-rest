/** 初始化 restapi 服务 */

const restify = require('restify');
const _ = require('lodash');
const Router = require('open-router');
const utils = require('./utils');

const plugins = [];
const rest = {};

/**
 * 激活插件
 */
const activePlugin = (path) => {
  plugins.forEach((x) => x(rest, path));
};

/**
 * 注册插件
 */
rest.plugin = (...values) => {
  values.forEach((x) => plugins.push(x));
  return rest;
};

/**
 * 根据传递进来的 path 构建 restapi 服务
 */
rest.start = (path, callback) => {
  activePlugin(path);

  const { service } = utils.require(`${path}/configs`);
  const routes = utils.require(`${path}/routes`);
  const middleWares = utils.require(`${path}/middle-wares`);
  const controllers = utils.getModules(`${path}/controllers`, 'js');

  const server = restify.createServer({
    name: service.name,
    version: service.version,
  });
  const middleWareIterator = (middleWare) => (
    server.use((req, res, next) => {
      try {
        middleWare(req, res, next);
      } catch (error) {
        utils.logger.error(req.url, error);
        next(error);
      }
    })
  );
  const CHARSET_FORCE = service.charset || 'utf-8';

  /** 设置中间件 */
  server.use(restify.acceptParser(server.acceptable));
  server.use(restify.queryParser(service.queryParser || null));
  server.use(restify.bodyParser(service.bodyParser || null));
  server.use((req, res, next) => {
    /**
     * 初始化 hooks
     * 因为后续要通过 req.hooks 来传递一些共用的变量
     */
    req.hooks = {};
    /** 强制处理字符集, 避免编码问题带来的隐患 */
    res.charSet(CHARSET_FORCE);
    next();
  });

  /** 自定义中间件 */
  _.each(middleWares, middleWareIterator);

  /**
   * 路由初始化、控制器载入
   * 这样同样要处理es6 import的兼容问题
   */
  routes(new Router(server, controllers, null, service.route));

  /** 监听错误，打印出来，方便调试 */
  server.on('uncaughtException', (req, res, route, error) => {
    utils.logger.error(route, error);
    if (!res.finished) res.send(500, 'Internal error');
  });

  return server.listen(service.port, service.ip, (error) => callback(error, server));
};

module.exports = rest;
