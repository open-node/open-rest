const assert = require('assert');
const _ = require('lodash');
const utils = require('../lib/utils');
const { db } = require('./app/configs');
const model = require('../lib/model');

describe('lib/model', () => {
  describe('#init', () => {
    const errorLog = utils.logger.error;
    utils.logger.error = () => {};

    it('model dir non-exists', (done) => {
      model.init(db, `${__dirname}/models-non-exists`, true);
      assert.ok(true);

      done();
    });

    it('model dir exists', (done) => {
      model.init(db, `${__dirname}/models`);

      assert.ok(true);
      done();
    });

    it('check model', (done) => {
      assert.ok(model('user'));
      assert.ok(model('team'));
      assert.ok(model('book'));

      assert.deepEqual(['book', 'team', 'user'], _.sortBy(_.keys(model())));

      done();
    });

    it('table-sync ENV is development', (done) => {
      const NODE_ENV = process.env.NODE_ENV;
      const infoLog = utils.logger.info;

      process.env.NODE_ENV = 'development';

      _.each(model(), (Model) => {
        Model.sync = () => (
          new Promise((resolve) => {
            setTimeout(() => {
              resolve(Model.name);
            }, 10);
          })
        );
      });

      utils.logger.info = (synced, table) => {
        assert.equal('Synced', synced);
        assert.ok(_.includes(['book', 'team', 'user'], table));
      };

      process.argv.push('table-sync');

      model.init(db, `${__dirname}/models`);

      utils.logger.info = infoLog;
      process.env.NODE_ENV = NODE_ENV;
      process.argv.pop();
      done();
    });

    it('table-sync ENV is development, exclude table-sync in argv', (done) => {
      const NODE_ENV = process.env.NODE_ENV;
      const infoLog = utils.logger.info;

      process.env.NODE_ENV = 'development';
      model.init(db, `${__dirname}/models`);

      utils.logger.error = errorLog;
      utils.logger.info = infoLog;
      process.env.NODE_ENV = NODE_ENV;
      done();
    });
  });
});
