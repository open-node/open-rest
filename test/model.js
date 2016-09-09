var assert  = require('assert')
  , _       = require('lodash')
  , utils   = require('../lib/utils')
  , model   = require('../lib/model');

describe('lib/model', function() {

  describe('#init', function() {
    var errorLog = utils.logger.error;
    utils.logger.error = function() {};

    it('model dir non-exists', function(done) {
      model.init({}, __dirname + '/models-non-exists');
      assert.ok(true);

      done();
    });

    it('model dir exists', function(done) {
      model.init({}, __dirname + '/models');

      assert.ok(true);
      done();
    });

    it('check model', function(done) {
      assert.ok(model('user'));
      assert.ok(model('team'));
      assert.ok(model('book'));

      assert.deepEqual(['book', 'team', 'user'], _.sortBy(_.keys(model())));

      done();
    });

    it('table-sync ENV is development', function(done) {
      var NODE_ENV = process.env.NODE_ENV;
      var infoLog = utils.logger.info;

      process.env.NODE_ENV = 'development';

      _.each(model(), function(Model) {
        Model.sync = function() {
          return new Promise(function(resolve, reject) {
            setTimeout(function() {
              resolve(Model.name);
            }, 10);
          });
        };
      });

      utils.logger.info = function(synced, table) {
        assert.equal('Synced', synced);
        assert.ok(_.includes(['book', 'team', 'user'], table));
      };

      process.argv.push('table-sync');

      model.init({}, __dirname + '/models');

      utils.logger.info = infoLog;
      process.env.NODE_ENV = NODE_ENV;
      process.argv.pop();
      done();
    });

    it('table-sync ENV is development, exclude table-sync in argv', function(done) {
      var NODE_ENV = process.env.NODE_ENV;
      var infoLog = utils.logger.info;

      process.env.NODE_ENV = 'development';

      model.init({}, __dirname + '/models');

      utils.logger.error = errorLog;
      utils.logger.info = infoLog;
      process.env.NODE_ENV = NODE_ENV;
      done();
    });

  });

});
