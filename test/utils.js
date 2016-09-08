var assert  = require('assert')
  , _       = require('lodash')
  , utils   = require('../lib/utils');

describe('Utils', function() {

  describe('#intval', function() {
    it("noraml", function(done) {
      assert.equal(2, utils.intval(2));
      return done();
    });
    it("string 2", function(done) {
      assert.equal(2, utils.intval('2'));
      return done();
    });
    it("string 2aa", function(done) {
      assert.equal(2, utils.intval('2aa'));
      return done();
    });
    it("8 mode 10", function(done) {
      assert.equal(8, utils.intval('10', 8));
      return done();
    });
    return it("string aaa, result is number 0", function(done) {
      assert.equal(0, utils.intval('aaa'));
      return done();
    });
  });

  describe('#file2Module', function() {
    it("filename return filename", function(done) {
      assert.equal('filename', utils.file2Module('filename'));
      return done();
    });
    return it("file-name return fileName", function(done) {
      assert.equal('fileName', utils.file2Module('file-name'));
      return done();
    });
  });

  describe('#nt2space', function() {

    it('行首和行尾的空格应该被替换掉', function(done) {
      assert.equal('first', utils.nt2space(' first '));
      return done();
    });

    it('换行符、空格和制表符应该被替换为一个空格', function(done) {
      assert.equal('first second end', utils.nt2space('first\n\t\r\f\v  second\\n\\t\\f\\v\\r end'));
      return done();
    });

    it('n,t,r,f,v不应该被替换掉', function(done) {
      assert.equal('ntrfv', utils.nt2space('ntrfv'));
      return done();
    });

    it('isnt a string', function(done) {

      assert.equal(0, utils.nt2space(0));
      assert.equal(1, utils.nt2space(1));
      assert.deepEqual([1], utils.nt2space([1]));
      assert.deepEqual({name: 'Hello'}, utils.nt2space({name: 'Hello'}));

      done();
    });

  });

  describe('#getToken', function() {
    return it("优先获取头信息里的 x-auth-token", function(done) {
      var req;
      req = {
        headers: {
          "x-auth-token": "Hi, I'm token"
        },
        params: {
          access_token: "access_token",
          accessToken: "accessToken"
        }
      };
      assert.equal("Hi, I'm token", utils.getToken(req));
      req.headers = {};
      assert.equal("access_token", utils.getToken(req));
      req.params.access_token = null;
      assert.equal("accessToken", utils.getToken(req));
      return done();
    });
  });

  describe('#randStr', function() {

    it('Length is 5', function(done) {
      assert.equal(5, utils.randStr(5).length);
      assert.equal(5, utils.randStr(5).length);
      assert.equal(5, utils.randStr(5).length);
      return done();
    });

    it('Type must be string', function(done) {
      assert.equal('string', typeof utils.randStr(5));
      assert.equal('string', typeof utils.randStr(5));
      assert.equal('string', typeof utils.randStr(5));
      return done();
    });

    it('Strong RAND_STR_DICT', function(done) {
      assert.equal(5, utils.randStr(5, 'strong').length);
      assert.equal('string', typeof utils.randStr(5, 'strong'));
      return done();
    });

    it('len lt 1', function(done) {
      assert.equal(3, utils.randStr(-1).length);
      done();
    });

    it('type non-exists, type as dist', function(done) {
      assert.equal(11111, +utils.randStr(5, '1'));

      done();
    });

  });

  describe('#ucwords', function() {

    it("value isnt a string", function(done) {
      assert.equal(123456, utils.ucwords(123456));

      done();
    });

    it('normal', function(done) {
      assert.equal('String', utils.ucwords('string'))
      assert.equal('String', utils.ucwords('String'))
      assert.equal('String', utils.ucwords(new String('string')))
      assert.equal('String', utils.ucwords(new String('String')))

      done();
    });

  });

  describe('#callback', function() {

    it("then branch", function(done) {
      var promise = new Promise(function(resolve, reject) {
        setTimeout(function() {
          resolve(20);
        }, 10);
      });

      utils.callback(promise, function(error, result) {

        try {
          assert.equal(null, error);
          assert.equal(20, result);
        } catch (e) {
          return done(e);
        }
        done();

      });
    });

    it("catch branch", function(done) {
      var promise = new Promise(function(resolve, reject) {
        setTimeout(function() {
          reject(Error('Hello world'));
        }, 10);
      });

      utils.callback(promise, function(error, result) {

        try {
          assert.ok(error instanceof Error);
          assert.equal('Hello world', error.message);
        } catch (e) {
          return done(e);
        }
        done();

      });
    });

  });

  describe('#getModules', function() {

    it('_path isnt a string', function(done) {
      assert.equal(0, utils.getModules(0));
      assert.deepEqual([0], utils.getModules([0]));

      done();
    });

    it('_path non-exists', function(done) {
      assert.deepEqual({}, utils.getModules(__dirname + '/non-exists-dir', ['js'], ['index']));

      done();
    });

    it('_path exists, exclude ', function(done) {
      assert.deepEqual({
        hello: 'This is a module, name is hello',
        es6Default: 'This is a es6 module, name is es6Default',
        helloWorld: 'This is a module, name is helloWorld'
      }, utils.getModules(__dirname + '/dir', ['js'], ['index']));

      done();
    });

    it('_path exists, exclude unset ', function(done) {
      assert.deepEqual({
        hello: 'This is a module, name is hello',
        es6Default: 'This is a es6 module, name is es6Default',
        helloWorld: 'This is a module, name is helloWorld',
        index: 'This is a module, name is index'
      }, utils.getModules(__dirname + '/dir', ['js']));

      done();
    });

  });

  describe('#readdir', function() {

    it('_path isnt a string', function(done) {
      assert.throws(function() {
        utils.readdir(['hello'], 'js');
      }, function(error) {
        return error instanceof Error && error.message === 'path must be a string';
      });
      done();
    });

    it('_path exists, exclude ', function(done) {
      var actual = utils.readdir(__dirname + '/dir', 'js', 'index');
      actual = _.sortBy(actual);

      assert.deepEqual([
        'es6-default',
        'hello',
        'hello-world'
      ], actual);

      done();
    });

    it('_path exists, exclude unset ', function(done) {
      var actual = utils.readdir(__dirname + '/dir', ['js']);
      actual = _.sortBy(actual);
      assert.deepEqual([
        'es6-default',
        'hello',
        'hello-world',
        'index'
      ], actual);

      done();
    });

  });

  describe('#isPrivateIp', function() {
    var whiteList = ['192.168.4.115', '192.168.4.114'];

    it('return true', function(done) {
      assert.equal(true, utils.isPrivateIp('192.168.4.114', whiteList));
      assert.equal(true, utils.isPrivateIp('192.168.4.115', whiteList));

      done()
    });

    it('return false', function(done) {
      assert.equal(false, utils.isPrivateIp('192.168.6.114', whiteList));
      assert.equal(false, utils.isPrivateIp('192.168.6.115', whiteList));

      done()
    });

  });

  describe('#remoteIp', function() {

    it('connection.remoteAddress exists', function(done) {
      var req = {
        connection: { remoteAddress: '58.215.168.153' }
      };
      assert.equal('58.215.168.153', utils.remoteIp(req));

      done();
    });

    it('socket.remoteAddress exists', function(done) {
      var req = {
        socket: { remoteAddress: '58.215.168.153' }
      };
      assert.equal('58.215.168.153', utils.remoteIp(req));

      done();
    });

    it('connection.socket.remoteAddress exists', function(done) {
      var req = {
        connection: {
          socket: { remoteAddress: '58.215.168.153' }
        }
      };
      assert.equal('58.215.168.153', utils.remoteIp(req));

      done();
    });

  });

  describe('#clientIp', function() {

    it('x-forwarded-for exists', function(done) {
      var req = {
        headers: {
          "x-forwarded-for": '10.0.0.20'
        },
        connection: { remoteAddress: '58.215.168.153' }
      };
      assert.equal('10.0.0.20', utils.clientIp(req));

      done();
    });

    it('x-forwarded-for non-exists, x-real-ip exists', function(done) {
      var req = {
        headers: {
          "x-real-ip": '10.0.0.30'
        },
        connection: { remoteAddress: '58.215.168.153' }
      };
      assert.equal('10.0.0.30', utils.clientIp(req));

      done();
    });

    it('x-forwarded-for non-exists, x-real-ip non-exists', function(done) {
      var req = {
        headers: {
        },
        connection: { remoteAddress: '58.215.168.153' }
      };
      assert.equal('58.215.168.153', utils.clientIp(req));

      done();
    });

  });

  describe('#realIp', function() {
    var proxyIps = [
      '58.215.168.153'
    ];

    it('remoteIp in proxyIps', function(done) {
      var req = {
        headers: {
          "x-real-ip": '10.0.0.30'
        },
        connection: { remoteAddress: '58.215.168.153' }
      };
      assert.equal('10.0.0.30', utils.realIp(req, proxyIps));
      req.headers['x-real-ip'] = null;
      assert.equal('58.215.168.153', utils.realIp(req, proxyIps));

      done();
    });

    it('remoteIp not in proxyIps', function(done) {
      var req = {
        headers: {
          "x-real-ip": '10.0.0.30'
        },
        connection: { remoteAddress: '58.215.168.169' }
      };
      assert.equal('58.215.168.169', utils.realIp(req));

      done();
    });

  });

  describe('#getSql', function() {

    it('keyword exists', function(done) {
      assert.equal('SELECT SQL_NO_CACHE * FROM `user` WHERE `id`>20 ORDER BY `id` DESC LIMIT 10, 200', utils.getSql({
        select: '*',
        table: '`user`',
        where: '`id`>20',
        sort: '`id` DESC',
        limit: '10, 200'
      }, 'SQL_NO_CACHE'));

      done();
    });

    it('keyword non-exists', function(done) {
      assert.equal('SELECT * FROM `user` GROUP BY `gender`', utils.getSql({
        select: '*',
        table: '`user`',
        group: '`gender`'
      }));

      done();
    });
  });

});
