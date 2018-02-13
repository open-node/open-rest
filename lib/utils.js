const fs = require('fs');
const _ = require('lodash');

const _require = require;
const hasOwnProperty = Object.prototype.hasOwnProperty;

/** 随机字符串字典 */
const RAND_STR_DICT = {
  normal: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
  strong: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&’()*+,-./:;<=>?@[]^_`{|}~',
};

const utils = {

  /**
   * 把 callback 的写法，作用到 promise 上
   * promise.then(->callback(null)).catch(callback)
   * 目的是为了让callback的写法可以快速对接到 promise 上
   */
  callback(promise, callback) {
    return promise.then((result) => {
      callback.call(null, null, result);
    }).catch(callback);
  },

  /**
   * 将字符串转换为数字
   */
  intval(value, mode) {
    return parseInt(value, mode || 10) || 0;
  },

  /** 根据设置的路径，获取对象 */
  getModules(_path, exts, excludes) {
    const modules = {};

    if (!_.isString(_path)) return _path;
    if (!fs.existsSync(_path)) return modules;

    _.each(utils.readdir(_path, exts, excludes), (file) => {
      const name = utils.file2Module(file);
      modules[name] = utils.es6import(_require(`${_path}/${file}`));
    });

    return modules;
  },

  /**
   * 兼容 es6 的 export
   */
  es6import(obj) {
    const isES6 = _.size(obj) === 1 && hasOwnProperty.call(obj, 'default');
    return isES6 ? obj.default : obj;
  },

  /**
   * 判断给定ip是否是白名单里的ip地址
   */
  isPrivateIp(ip, whiteList = []) {
    return whiteList.includes(ip);
  },

  /** 真实的连接请求端ip */
  remoteIp(req) {
    const { connection, socket } = req;
    return (connection && connection.remoteAddress) ||
      (socket && socket.remoteAddress) ||
      (connection && connection.socket && connection.socket.remoteAddress);
  },

  /**
   * 获取客户端真实ip地址
   */
  clientIp(req) {
    return (
      req.headers['x-forwarded-for'] ||
      req.headers['x-real-ip'] ||
      utils.remoteIp(req)
    ).split(',')[0];
  },

  /**
   * 获取可信任的真实ip
   */
  realIp(req, proxyIps) {
    const remoteIp = utils.remoteIp(req);
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
  readdir(dir, ext, exclude) {
    const exts = _.isString(ext) ? [ext] : ext;
    const excludes = _.isString(exclude) ? [exclude] : exclude;
    return _.chain(fs.readdirSync(dir))
      .map((x) => x.split('.'))
      .filter((x) => _.includes(exts, x[1]) && !_.includes(excludes, x[0]))
      .map((x) => x[0])
      .value();
  },

  /**
   * 文件名称到moduleName的转换
   * example, twe cases
   * case1. filename => filename
   * case2. file-name => fileName
   */
  file2Module(file) {
    return file.replace(/(-\w)/g, (m) => m[1].toUpperCase());
  },

  /** 首字符大写 */
  ucwords(value) {
    if (!_.isString(value)) return value;
    return value[0].toUpperCase() + value.substring(1);
  },

  /** 将字符串里的换行，制表符替换为普通空格 */
  nt2space(value) {
    if (!_.isString(value)) return value;
    /** 将换行、tab、多个空格等字符换成一个空格 */
    return value.replace(/(\\[ntrfv]|\s)+/g, ' ').trim();
  },

  /** 获取accessToken */
  getToken(req) {
    return req.headers['x-auth-token'] || req.params.access_token || req.params.accessToken;
  },

  /** 根据条件拼接sql语句 */
  getSql(option, keyword) {
    const sqls = ['SELECT'];
    if (keyword) sqls.push(keyword);
    sqls.push(option.select);
    sqls.push(`FROM ${option.table}`);
    if (option.where) sqls.push(`WHERE ${option.where}`);
    if (option.group) sqls.push(`GROUP BY ${option.group}`);
    if (option.sort) sqls.push(`ORDER BY ${option.sort}`);
    if (option.limit) sqls.push(`LIMIT ${option.limit}`);
    return sqls.join(' ');
  },

  /**
   * 生成随机字符串
   * @params
   *   len int.unsigned 生成的随机串的长度
   *   type enum('normal', 'strong') 随即串的强度, defaultValue is normal
   */
  randStr(_len, type) {
    const dict = RAND_STR_DICT[type || 'normal'] || type;
    const length = dict.length;

    /** 随机字符串的长度不能等于 0 或者负数*/
    const len = utils.intval(_len) < 1 ? 3 : _len;

    return _.range(len).map(() => dict[Math.floor(Math.random() * length)]).join('');
  },

  /** 处理日志 */
  logger: {
    info: console.info.bind(console),
    error: console.error.bind(console),
    warn: console.warn.bind(console),
  },

  /** 加载模块，屏蔽错误*/
  require(path) {
    try {
      return _require(path);
    } catch (e) {
      return null;
    }
  },

  isTest: process.env.NODE_ENV === 'test',

  isProd: process.env.NODE_ENV === 'production',

};

module.exports = utils;
