const assert = require('assert');
const _ = require('lodash');
const utils = require('../lib/utils');

describe('lib/utils', () => {
  describe('#intval', () => {
    it('noraml', (done) => {
      assert.equal(2, utils.intval(2));
      return done();
    });
    it('string 2', (done) => {
      assert.equal(2, utils.intval('2'));
      return done();
    });
    it('string 2aa', (done) => {
      assert.equal(2, utils.intval('2aa'));
      return done();
    });
    it('8 mode 10', (done) => {
      assert.equal(8, utils.intval('10', 8));
      return done();
    });
    return it('string aaa, result is number 0', (done) => {
      assert.equal(0, utils.intval('aaa'));
      return done();
    });
  });

  describe('#file2Module', () => {
    it('filename return filename', (done) => {
      assert.equal('filename', utils.file2Module('filename'));
      return done();
    });
    return it('file-name return fileName', (done) => {
      assert.equal('fileName', utils.file2Module('file-name'));
      return done();
    });
  });

  describe('#nt2space', () => {
    it('行首和行尾的空格应该被替换掉', (done) => {
      assert.equal('first', utils.nt2space(' first '));
      return done();
    });

    it('换行符、空格和制表符应该被替换为一个空格', (done) => {
      const result = utils.nt2space('first\n\t\r\f\v  second\\n\\t\\f\\v\\r end');
      assert.equal('first second end', result);
      return done();
    });

    it('n,t,r,f,v不应该被替换掉', (done) => {
      assert.equal('ntrfv', utils.nt2space('ntrfv'));
      return done();
    });

    it('isnt a string', (done) => {
      assert.equal(0, utils.nt2space(0));
      assert.equal(1, utils.nt2space(1));
      assert.deepEqual([1], utils.nt2space([1]));
      assert.deepEqual({ name: 'Hello' }, utils.nt2space({ name: 'Hello' }));

      done();
    });
  });

  describe('#getToken', () => {
    it('优先获取头信息里的 x-auth-token', (done) => {
      const req = {
        headers: {
          'x-auth-token': 'Hi, I\'m token',
        },
        params: {
          access_token: 'access_token',
          accessToken: 'accessToken',
        },
      };
      assert.equal('Hi, I\'m token', utils.getToken(req));
      req.headers = {};
      assert.equal('access_token', utils.getToken(req));
      req.params.access_token = null;
      assert.equal('accessToken', utils.getToken(req));
      done();
    });
  });

  describe('#randStr', () => {
    it('Length is 5', (done) => {
      assert.equal(5, utils.randStr(5).length);
      assert.equal(5, utils.randStr(5).length);
      assert.equal(5, utils.randStr(5).length);
      done();
    });

    it('Type must be string', (done) => {
      assert.equal('string', typeof utils.randStr(5));
      assert.equal('string', typeof utils.randStr(5));
      assert.equal('string', typeof utils.randStr(5));
      done();
    });

    it('Strong RAND_STR_DICT', (done) => {
      assert.equal(5, utils.randStr(5, 'strong').length);
      assert.equal('string', typeof utils.randStr(5, 'strong'));
      done();
    });

    it('len lt 1', (done) => {
      assert.equal(3, utils.randStr(-1).length);
      done();
    });

    it('type non-exists, type as dist', (done) => {
      assert.equal(11111, +utils.randStr(5, '1'));

      done();
    });
  });

  describe('#ucwords', () => {
    it('value isnt a string', (done) => {
      assert.equal(123456, utils.ucwords(123456));

      done();
    });

    it('normal', (done) => {
      assert.equal('String', utils.ucwords('string'));
      assert.equal('String', utils.ucwords(String('string')));

      done();
    });
  });

  describe('#callback', () => {
    it('then branch', (done) => {
      const promise = new Promise((resolve) => {
        setTimeout(() => {
          resolve(20);
        }, 10);
      });

      utils.callback(promise, (error, result) => {
        try {
          assert.equal(null, error);
          assert.equal(20, result);
        } catch (e) {
          return done(e);
        }
        return done();
      });
    });

    it('catch branch', (done) => {
      const promise = new Promise((resolve, reject) => {
        setTimeout(() => {
          reject(Error('Hello world'));
        }, 10);
      });

      utils.callback(promise, (error) => {
        try {
          assert.ok(error instanceof Error);
          assert.equal('Hello world', error.message);
        } catch (e) {
          return done(e);
        }
        return done();
      });
    });
  });

  describe('#getModules', () => {
    it('_path isnt a string', (done) => {
      assert.equal(0, utils.getModules(0));
      assert.deepEqual([0], utils.getModules([0]));

      done();
    });

    it('_path non-exists', (done) => {
      assert.deepEqual({}, utils.getModules(`${__dirname}/non-exists-dir`, ['js'], ['index']));

      done();
    });

    it('_path exists, exclude ', (done) => {
      assert.deepEqual({
        hello: 'This is a module, name is hello',
        es6Default: 'This is a es6 module, name is es6Default',
        helloWorld: 'This is a module, name is helloWorld',
      }, utils.getModules(`${__dirname}/dir`, ['js'], ['index']));

      done();
    });

    it('_path exists, exclude unset ', (done) => {
      assert.deepEqual({
        hello: 'This is a module, name is hello',
        es6Default: 'This is a es6 module, name is es6Default',
        helloWorld: 'This is a module, name is helloWorld',
        index: 'This is a module, name is index',
      }, utils.getModules(`${__dirname}/dir`, ['js']));

      done();
    });
  });

  describe('#readdir', () => {
    it('_path isnt a string', (done) => {
      assert.throws(() => {
        utils.readdir(['hello'], 'js');
      }, (error) => (
        error instanceof Error && (
          error.message === 'path must be a string' ||
          error.message === 'path must be a string or Buffer'
        )
      ));
      done();
    });

    it('_path exists, exclude ', (done) => {
      const actual = _.sortBy(utils.readdir(`${__dirname}/dir`, 'js', 'index'));

      assert.deepEqual([
        'es6-default',
        'hello',
        'hello-world',
      ], actual);

      done();
    });

    it('_path exists, exclude unset ', (done) => {
      const actual = _.sortBy(utils.readdir(`${__dirname}/dir`, ['js']));
      assert.deepEqual([
        'es6-default',
        'hello',
        'hello-world',
        'index',
      ], actual);

      done();
    });
  });

  describe('#isPrivateIp', () => {
    const whiteList = ['192.168.4.115', '192.168.4.114'];

    it('return true', (done) => {
      assert.equal(true, utils.isPrivateIp('192.168.4.114', whiteList));
      assert.equal(true, utils.isPrivateIp('192.168.4.115', whiteList));

      done();
    });

    it('return false', (done) => {
      assert.equal(false, utils.isPrivateIp('192.168.6.114', whiteList));
      assert.equal(false, utils.isPrivateIp('192.168.6.115', whiteList));

      done();
    });

    it('whiteList is null', (done) => {
      assert.equal(false, utils.isPrivateIp('192.168.6.114'));

      done();
    });
  });

  describe('#remoteIp', () => {
    it('connection.remoteAddress exists', (done) => {
      const req = { connection: { remoteAddress: '58.215.168.153' } };
      assert.equal('58.215.168.153', utils.remoteIp(req));

      done();
    });

    it('socket.remoteAddress exists', (done) => {
      const req = { socket: { remoteAddress: '58.215.168.153' } };
      assert.equal('58.215.168.153', utils.remoteIp(req));

      done();
    });

    it('connection.socket.remoteAddress exists', (done) => {
      const req = { connection: { socket: { remoteAddress: '58.215.168.153' } } };
      assert.equal('58.215.168.153', utils.remoteIp(req));

      done();
    });
  });

  describe('#clientIp', () => {
    it('x-forwarded-for exists', (done) => {
      const req = {
        headers: { 'x-forwarded-for': '10.0.0.20' },
        connection: { remoteAddress: '58.215.168.153' },
      };
      assert.equal('10.0.0.20', utils.clientIp(req));

      done();
    });

    it('x-forwarded-for non-exists, x-real-ip exists', (done) => {
      const req = {
        headers: { 'x-real-ip': '10.0.0.30' },
        connection: { remoteAddress: '58.215.168.153' },
      };
      assert.equal('10.0.0.30', utils.clientIp(req));

      done();
    });

    it('x-forwarded-for non-exists, x-real-ip non-exists', (done) => {
      const req = {
        headers: {},
        connection: { remoteAddress: '58.215.168.153' },
      };
      assert.equal('58.215.168.153', utils.clientIp(req));

      done();
    });
  });

  describe('#realIp', () => {
    const proxyIps = ['58.215.168.153'];

    it('remoteIp in proxyIps', (done) => {
      const req = {
        headers: { 'x-real-ip': '10.0.0.30' },
        connection: { remoteAddress: '58.215.168.153' },
      };
      assert.equal('10.0.0.30', utils.realIp(req, proxyIps));
      req.headers['x-real-ip'] = null;
      assert.equal('58.215.168.153', utils.realIp(req, proxyIps));

      done();
    });

    it('remoteIp not in proxyIps', (done) => {
      const req = {
        headers: { 'x-real-ip': '10.0.0.30' },
        connection: { remoteAddress: '58.215.168.169' },
      };
      assert.equal('58.215.168.169', utils.realIp(req));

      done();
    });
  });

  describe('#getSql', () => {
    it('keyword exists', (done) => {
      const expect = [
        'SELECT SQL_NO_CACHE *',
        'FROM `user`',
        'WHERE `id`>20',
        'ORDER BY `id` DESC',
        'LIMIT 10, 200',
      ].join(' ');
      assert.equal(expect, utils.getSql({
        select: '*',
        table: '`user`',
        where: '`id`>20',
        sort: '`id` DESC',
        limit: '10, 200',
      }, 'SQL_NO_CACHE'));

      done();
    });

    it('keyword non-exists', (done) => {
      assert.equal('SELECT * FROM `user` GROUP BY `gender`', utils.getSql({
        select: '*',
        table: '`user`',
        group: '`gender`',
      }));

      done();
    });
  });

  describe('#require', () => {
    it('require non-exists module', (done) => {
      assert.equal(null, utils.require(`${__dirname}/hello-world`));
      done();
    });
  });
});
