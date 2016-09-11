var helper = require('../lib/helper')
  , assert = require('assert');

describe('helper', function() {

  describe('#console', function() {

    it('console.log', function(done) {
      var _log = console.log
        , log = helper.console.log('hello', 'world');

      console.log = function(arg1, arg2) {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, function(error) {
        assert.equal(null, error);
        console.log = _log;

        done();
      });
    });

    it('console.info', function(done) {
      var _log = console.info
        , log = helper.console.info('hello', 'world');

      console.info = function(arg1, arg2) {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, function(error) {
        assert.equal(null, error);
        console.info = _log;

        done();
      });
    });

    it('console.error', function(done) {
      var _log = console.error
        , log = helper.console.error('hello', 'world');

      console.error = function(arg1, arg2) {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, function(error) {
        assert.equal(null, error);
        console.error = _log;

        done();
      });
    });

    it('console.warn', function(done) {
      var _log = console.warn
        , log = helper.console.warn('hello', 'world');

      console.warn = function(arg1, arg2) {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, function(error) {
        assert.equal(null, error);
        console.warn = _log;

        done();
      });
    });

    it('console.time', function(done) {
      var _log = console.time
        , log = helper.console.time('hello');

      console.time = function(arg1) {
        assert.equal('hello', arg1);
      };

      log(null, null, function(error) {
        assert.equal(null, error);
        console.time = _log;

        done();
      });
    });

    it('console.timeEnd', function(done) {
      var _log = console.timeEnd
        , log = helper.console.timeEnd('hello');

      console.timeEnd = function(arg1) {
        assert.equal('hello', arg1);
      };

      log(null, null, function(error) {
        assert.equal(null, error);
        console.timeEnd = _log;

        done();
      });
    });

  });

});
