var fs        = require('fs')
  , path      = require('path')
  , _         = require('lodash');

/** 随机字符串字典 */
var RAND_STR_DICT = {
  normal: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
  strong: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()_+<>{}|\=-`~'
};

utils = {

  /**
   * 把 callback 的写法，作用到 promise 上
   * promise.then(->callback(null)).catch(callback)
   * 目的是为了让callback的写法可以快速对接到 promise 上
   */
  callback: function(promise, callback) {
    return promise.then(function(result) {
      callback.call(null, null, result)
    }).catch(callback);
  },

  /**
   * 将字符串转换为数字
   */
  intval: function(value, mode) {
    return parseInt(value, mode || 10) || 0
  },

  /** 根据设置的路径，获取对象 */
  getModules: function(_path, exts, excludes) {
    var modules = {};

    if (!_.isString(_path)) return _path;
    if (!fs.existsSync(_path)) return modules;

    _.each(utils.readdir(_path, exts, excludes), function(file) {
      var name = utils.file2Module(file);
      modules[name] = utils.es6import(require(_path + '/' + file));
    });

    return modules;
  },

  /**
   * 兼容 es6 的 export
   */
  es6import: function(obj) {
    var isES6 = _.size(obj) === 1 && obj.hasOwnProperty('default');
    return isES6 ? obj.default : obj;
  },

  /**
   * 判断给定ip是否是白名单里的ip地址
   */
  isPrivateIp: function(ip, whiteList) {
    return _.includes(whiteList, ip);
  },

  /** 真实的连接请求端ip */
  remoteIp: function(req) {
    return (
      req.connection && req.connection.remoteAddress ||
      req.socket && req.socket.remoteAddress ||
      (
        req.connection && req.connection.socket &&
        req.connection.socket.remoteAddress
      )
    );
  },

  /**
   * 获取客户端真实ip地址
   */
  clientIp: function(req) {
    return (
      req.headers['x-forwarded-for'] ||
      req.headers['x-real-ip'] ||
      utils.remoteIp(req)
    ).split(',')[0];
  },

  /**
   * 获取可信任的真实ip
   */
  realIp: function(req, proxyIps) {
    var remoteIp = utils.remoteIp(req);
    if (!_.includes(proxyIps || [], remoteIp)) return remoteIp;
    return req.headers['x-real-ip'] || remoteIp;
  },

  /*
   * 读取录下的所有模块，之后返回数组
   * 对象的key是模块的名称，值是模块本身
   * params
   *   dir 要加载的目录
   *   exts 要加载的模块文件后缀，多个可以是数组, 默认为 coffee
   *   excludes 要排除的文件, 默认排除 index
   */
  readdir: function(dir, exts, excludes) {
    if (_.isString(exts)) exts = [exts];
    if (_.isString(excludes)) excludes = [excludes];
    return _.chain(fs.readdirSync(dir))
      .map(function(x) { return x.split('.'); })
      .filter(function(x) {
        return _.includes(exts, x[1]) && !_.includes(excludes, x[0]);
      })
      .map(function(x) { return x[0]; })
      .value();
  },

  /**
   * 文件名称到moduleName的转换
   * example, twe cases
   * case1. filename => filename
   * case2. file-name => fileName
   */
  file2Module: function(file) {
    return file.replace(/(\-\w)/g, function(m) {
      return m[1].toUpperCase();
    });
  },

  /** 首字符大写 */
  ucwords: function(value) {
    if (!_.isString(value)) return value;
    return value[0].toUpperCase() + value.substring(1);
  },

  /** 将字符串里的换行，制表符替换为普通空格 */
  nt2space: function(value) {
    if (!_.isString(value)) return value;
    /** 将换行、tab、多个空格等字符换成一个空格 */
    return value.replace(/(\\[ntrfv]|\s)+/g, ' ').trim()
  },

  /** 获取accessToken */
  getToken: function(req) {
    return (
      req.headers['x-auth-token'] ||
      req.params.access_token ||
      req.params.accessToken
    );
  },

  /** 根据条件拼接sql语句 */
  getSql: function(option, keyword) {
    var sqls = ['SELECT'];
    if (keyword) sqls.push(keyword);
    sqls.push(option.select);
    sqls.push('FROM ' + option.table);
    if (option.where) sqls.push('WHERE ' + option.where);
    if (option.group) sqls.push('GROUP BY ' + option.group);
    if (option.sort) sqls.push('ORDER BY ' + option.sort);
    if (option.limit) sqls.push('LIMIT ' + option.limit);
    return sqls.join(' ');
  },

  /**
   * 生成随机字符串
   * @params
   *   len int.unsigned 生成的随机串的长度
   *   type enum('normal', 'strong') 随即串的强度, defaultValue is normal
   */
  randStr: function(len, type) {
    var dict = RAND_STR_DICT[type || 'normal'] || type
      , length = dict.length;

    /** 随机字符串的长度不能等于 0 或者负数*/
    if (utils.intval(len) < 1) len = 3;

    return _.map(_.times(len), function() {
      return dict[Math.floor(Math.random() * length)]
    }).join('');
  },

  /** 处理日志 */
  logger: {
    info: console.info.bind(console),
    error: console.error.bind(console),
    warn: console.warn.bind(console)
  }
};

module.exports = utils;
