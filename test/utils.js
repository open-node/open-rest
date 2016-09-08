var assert = require('assert')
  , utils = require('../lib/utils');

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
    return it('n,t,r,f,v不应该被替换掉', function(done) {
      assert.equal('ntrfv', utils.nt2space('ntrfv'));
      return done();
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
    return it('Strong RAND_STR_DICT', function(done) {
      assert.equal(5, utils.randStr(5, 'strong').length);
      assert.equal('string', typeof utils.randStr(5, 'strong'));
      return done();
    });
  });

});
