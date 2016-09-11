var rest   = require('../')
  , _      = require('lodash')
  , assert = require('assert');

describe('integrate', function() {

  describe('#un-init', function() {

    it('check type', function(done) {
      assert.ok(rest instanceof Function);

      done();
    });

    it('uncaughtException', function(done) {
      var errorLog = rest.utils.logger.error;
      rest.utils.logger.error = function(error) {
        assert.ok(error instanceof Error);
        assert.equal('Hello this is a uncaught expection.', error.message);
        rest.utils.logger.error = errorLog;

        done();
      };

      setTimeout(function() {
        throw Error('Hello this is a uncaught expection.');
      }, 10);

    });

    it('rejectionHandled', function(done) {
      var errorLog = rest.utils.logger.error
        , promise;
      rest.utils.logger.error = function(error) {
        assert.ok(error instanceof Error);
        assert.equal('Hello this is a unregist rejection', error.message);
        rest.utils.logger.error = errorLog;

        done();
      };

      promise = new Promise(function(resolve, reject) {
        setTimeout(function() {
          reject(Error('Hello this is a unregist rejection'));
        }, 10);
      });
      promise.then(function() {
        console.log('Dont run here!')
      })

    });

    it('attach object check', function(done) {
      var attachs = [
        'Router', 'helper', 'model', 'utils',
        'errors', 'restify', 'Sequelize', 'mysql'
      ];
      _.each(attachs, function(x) {
        assert.ok(rest[x]);
      });

      done();
    });

  });

  describe('#inited', function() {

    var restify       = require('restify')
      , pkg           = require('../package')
      , U             = require('../lib/utils')
      , model         = require('../lib/model')
      , config        = require('./app/configs')
      , log           = U.logger.info
      , errorLog      = U.logger.error
      , createServer  = restify.createServer
      , modelInit     = model.init;

    restify.createServer = function(option) {
      assert.equal('open-rest', option.name);
      assert.equal(pkg.version, option.version);

      return createServer.call(restify, option);
    };

    model.init = function(db, modelPath) {
      assert.deepEqual(config.db, db);
      assert.equal(__dirname + '/app/models', modelPath);
      return modelInit.call(model, db, modelPath, true);
    };

    it('only difined root path', function(done) {
      U.logger.info = function() {};
      U.logger.error = function() {};

      rest(__dirname + '/app');

      setTimeout(function() {
        restify.createServer = createServer;
        U.logger.info = log;
        U.logger.error = errorLog;
        model.init = modelInit;
        done();
      }, 100);
    });


  });

});
