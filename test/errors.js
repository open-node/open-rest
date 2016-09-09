var assert  = require('assert')
  , _       = require('lodash')
  , utils   = require('../lib/utils')
  , errors  = require('../lib/errors');

describe('lib/errors', function() {

  describe('#notFound', function() {

    it("field unset, msg set", function(done) {
      var error = errors.notFound('Not found');

      assert.equal(404, error.statusCode);
      assert.deepEqual({
        code: 'ResourceNotFound',
        message: 'Not found'
      }, error.body);

      done();
    });

    it("field unset, msg unset", function(done) {
      var error = errors.notFound();

      assert.equal(404, error.statusCode);
      assert.deepEqual({
        code: 'ResourceNotFound',
        message: 'Resource not found.'
      }, error.body);

      done();
    });

    it("field set, msg set", function(done) {
      var error = errors.notFound('所属 Team 不存在', 'teamId');

      assert.equal(422, error.statusCode);
      assert.deepEqual({
        code: 'ArgumentError',
        message: [{
          message: '所属 Team 不存在',
          path: 'teamId'
        }]
      }, error.body);

      done();
    });

    it("field set, msg unset", function(done) {
      var error = errors.notFound(null, 'teamId');

      assert.equal(422, error.statusCode);
      assert.deepEqual({
        code: 'ArgumentError',
        message: [{
          message: 'Resource not found.',
          path: 'teamId'
        }]
      }, error.body);

      done();
    });

  });

  describe('#notAllowed', function() {

    it('msg unset', function(done) {
      var error = errors.notAllowed();
      assert.equal(403, error.statusCode);
      assert.deepEqual({
        code: 'ForbiddenError',
        message: 'Not allowed error.'
      }, error.body);

      done();
    });

    it('msg set', function(done) {
      var error = errors.notAllowed('您没有权限执行该操作。');
      assert.equal(403, error.statusCode);
      assert.deepEqual({
        code: 'ForbiddenError',
        message: '您没有权限执行该操作。'
      }, error.body);

      done();
    });

  });

  describe('#notAuth', function() {

    it('msg unset', function(done) {
      var error = errors.notAuth();
      assert.equal(403, error.statusCode);
      assert.deepEqual({
        code: 'NotAuthorized',
        message: 'Not authorized error.'
      }, error.body);

      done();
    });

    it('msg set', function(done) {
      var error = errors.notAuth('您没有权限执行该操作。');
      assert.equal(403, error.statusCode);
      assert.deepEqual({
        code: 'NotAuthorized',
        message: '您没有权限执行该操作。'
      }, error.body);

      done();
    });

  });

  describe('#invalidArgument', function() {

    it('msg unset, values unset', function(done) {
      var error = errors.invalidArgument();
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'InvalidArgument',
        message: 'Invalid argument error.'
      }, error.body);

      done();
    });

    it('msg unset, values set', function(done) {
      var error = errors.invalidArgument(null, [1, 2, 3]);
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'InvalidArgument',
        message: 'Invalid argument error.',
        value: [1, 2, 3]
      }, error.body);

      done();
    });

    it('msg set, values unset', function(done) {
      var error = errors.invalidArgument('参数不合法');
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'InvalidArgument',
        message: '参数不合法'
      }, error.body);

      done();
    });

    it('msg set, values set', function(done) {
      var error = errors.invalidArgument('参数不合法', [1, 2, 3]);
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'InvalidArgument',
        message: '参数不合法',
        value: [1, 2, 3]
      }, error.body);

      done();
    });

  });

  describe('#missingParameter', function() {

    it('msg unset, missings unset', function(done) {
      var error = errors.missingParameter();
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'MissingParameter',
        message: 'Missing parameter error.'
      }, error.body);

      done();
    });

    it('msg unset, missings set', function(done) {
      var error = errors.missingParameter(null, ['name', 'email']);
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'MissingParameter',
        message: 'Missing parameter error.',
        value: ['name', 'email']
      }, error.body);

      done();
    });

    it('msg set, missings unset', function(done) {
      var error = errors.missingParameter('Email 必须要提供');
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'MissingParameter',
        message: 'Email 必须要提供'
      }, error.body);

      done();
    });

    it('msg set, values set', function(done) {
      var error = errors.missingParameter('Email 必须要提供', 'email');
      assert.equal(409, error.statusCode);
      assert.deepEqual({
        code: 'MissingParameter',
        message: 'Email 必须要提供',
        value: 'email'
      }, error.body);

      done();
    });

  });

  describe('#sequelizeIfError', function() {

    it('error unset, field unset', function(done) {
      var error = errors.sequelizeIfError();
      assert.equal(null, error);

      done();
    });

    it('error unset, field set', function(done) {
      var error = errors.sequelizeIfError(null, 'name');
      assert.equal(null, error);

      done();
    });

    it('error set, field unset', function(done) {
      var error = errors.sequelizeIfError(Error('Hello world'));
      assert.equal(422, error.statusCode);
      assert.deepEqual({
        code: 'ArgumentError',
        message: 'Hello world'
      }, error.body);

      done();
    });

    it('error set, field set', function(done) {
      var error = errors.sequelizeIfError(Error('Email 必须要提供'), 'email');
      assert.equal(422, error.statusCode);
      assert.deepEqual({
        code: 'ArgumentError',
        message: [{
          message: 'Email 必须要提供',
          path: 'email'
        }]
      }, error.body);

      done();
    });

  });

  describe('#ifError', function() {

    it('error unset, field unset', function(done) {
      var error = errors.ifError();
      assert.equal(null, error);

      done();
    });

    it('error unset, field set', function(done) {
      var error = errors.ifError(null, 'name');
      assert.equal(null, error);

      done();
    });

    it('error set, field unset', function(done) {
      var error = errors.ifError(Error('Hello world'));
      assert.deepEqual(Error('Hello world'), error);

      done();
    });

    it('error set, field set', function(done) {
      var error = errors.ifError(Error('Email 必须要提供'), 'email');
      assert.equal(422, error.statusCode);
      assert.deepEqual({
        code: 'ArgumentError',
        message: [{
          message: 'Email 必须要提供',
          path: 'email'
        }]
      }, error.body);

      done();
    });

  });

  describe('#normalError', function() {

    it('msg unset, value... unset', function(done) {
      var error = errors.normalError();
      assert.equal(500, error.statusCode);
      assert.deepEqual({
        code: 'NormalError',
        message: [{
          message: 'Normal error.',
          values: []
        }]
      }, error.body);

      done();
    });

    it('msg unset, value... set', function(done) {
      var error = errors.normalError(null, 'name');
      assert.equal(500, error.statusCode);
      assert.deepEqual({
        code: 'NormalError',
        message: [{
          message: 'Normal error.',
          values: ['name']
        }]
      }, error.body);

      done();
    });

    it('msg set, value... unset', function(done) {
      var error = errors.normalError('出了点问题');
      assert.equal(500, error.statusCode);
      assert.deepEqual({
        code: 'NormalError',
        message: [{
          message: '出了点问题',
          values: []
        }]
      }, error.body);

      done();
    });

    it('msg set, value... set', function(done) {
      var error = errors.normalError('出了点问题', 'name', 'age');
      assert.equal(500, error.statusCode);
      assert.deepEqual({
        code: 'NormalError',
        message: [{
          message: '出了点问题',
          values: ['name', 'age']
        }]
      }, error.body);

      done();
    });

  });

  describe('#error', function() {

    it('msg unset, value... unset', function(done) {
      var error = errors.error();
      var err = Error('Unknown error.');
      err.value = []
      assert.deepEqual(err, error);

      done();
    });

    it('msg unset, value... set', function(done) {
      var error = errors.error(null, 'name');
      var err = Error('Unknown error.');
      err.value = ['name']
      assert.deepEqual(err, error);

      done();
    });

    it('msg set, value... unset', function(done) {
      var error = errors.error('出了点问题');
      var err = Error('出了点问题');
      err.value = []
      assert.deepEqual(err, error);

      done();
    });

    it('msg set, value... set', function(done) {
      var error = errors.error('出了点问题', 'name', 'age');
      var err = Error('出了点问题');
      err.value = ['name', 'age']
      assert.deepEqual(err, error);

      done();
    });

  });
});
