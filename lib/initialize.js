/** 初始化 restapi 服务 */

const restify = require('restify');
const _ = require('lodash');
const Router = require('open-router');
const utils = require('./utils');

/**
 * 根据传递进来的 opts 构建 restapi 服务
 * opts = {
 *   routers: routers, // required 路由的定义
 *   controllers: controllers, // required 控制器组
 *   middleWares: middleWares, // optional 中间件
 *   service: { // required 服务相关的开关
 *     name: 'Open-rest-api', // required api 服务名称
 *     version: '0.1.0', // required api 服务版本
 *     queryParser: null, // optional query 解析方法
 *     bodyParser: null, // optional body 解析方法
 *     route: {
 *       apis: '/apis', // optional 查询所有api的地址
 *     }
 *   }
 * }
 *
 */
module.exports = ({ routes, controllers, middleWares, service }) => {
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
  if (middleWares) _.each(middleWares, middleWareIterator);

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

  return server;
};
