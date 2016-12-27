const rest = require('../');
const _ = require('lodash');
const axios = require('axios');
const assert = require('assert');
const restify = require('restify');
const U = require('../lib/utils');
const model = require('../lib/model');
const config = require('./app/configs');

const hasOwnProperty = Object.prototype.hasOwnProperty;

describe('integrate', () => {
  describe('#un-init', () => {
    it('check type', (done) => {
      assert.ok(rest instanceof Function);

      done();
    });

    it('uncaughtException', (done) => {
      const errorLog = rest.utils.logger.error;
      rest.utils.logger.error = (error) => {
        assert.ok(error instanceof Error);
        assert.equal('Hello this is a uncaught expection.', error.message);
        rest.utils.logger.error = errorLog;

        done();
      };

      setTimeout(() => {
        throw Error('Hello this is a uncaught expection.');
      }, 10);
    });

    it('rejectionHandled', (done) => {
      const errorLog = rest.utils.logger.error;
      rest.utils.logger.error = (error) => {
        assert.ok(error instanceof Error);
        assert.equal('Hello this is a unregist rejection', error.message);
        rest.utils.logger.error = errorLog;

        done();
      };

      const promise = new Promise((resolve, reject) => {
        setTimeout(() => {
          reject(Error('Hello this is a unregist rejection'));
        }, 10);
      });
      setTimeout(() => {
        promise.then(() => {
          console.log('Dont run here!');
        });
      }, 10);
    });

    it('unhandleRejection', (done) => {
      const errorLog = rest.utils.logger.error;
      rest.utils.logger.error = (error) => {
        assert.ok(error instanceof Error);
        assert.equal('Hello this is a unregist rejection', error.message);
        rest.utils.logger.error = errorLog;

        done();
      };

      const promise = new Promise((resolve, reject) => {
        setTimeout(() => {
          reject(Error('Hello this is a unregist rejection'));
        }, 10);
      });
      promise.then(() => {
        console.log('Dont run here!');
      });
    });

    it('attach object check', (done) => {
      const attachs = [
        'Router', 'helper', 'model', 'utils',
        'errors', 'restify', 'Sequelize', 'mysql',
      ];
      _.each(attachs, (x) => {
        assert.ok(rest[x]);
      });

      done();
    });
  });

  describe('#inited', () => {
    const log = U.logger.info;
    const errorLog = U.logger.error;
    const createServer = restify.createServer;
    const modelInit = model.init;

    restify.createServer = (option) => {
      assert.equal('open-rest', option.name);
      assert.equal('1.0.0', option.version);

      return createServer.call(restify, option);
    };

    model.init = (db, modelPath) => {
      assert.deepEqual(config.db, db);
      assert.equal(`${__dirname}/app/models`, modelPath);
      return modelInit.call(model, db, modelPath, true);
    };

    it('only difined root path', (done) => {
      U.logger.info = () => {};
      U.logger.error = () => {};

      const listen = rest(`${__dirname}/app`, () => {
        restify.createServer = createServer;
        U.logger.info = log;
        U.logger.error = errorLog;
        model.init = modelInit;
        listen.close();

        done();
      });
    });

    it('define app path', (done) => {
      const _root = `${__dirname}/app`;
      U.logger.info = () => {};
      U.logger.error = () => {};

      const listen = rest({ appPath: _root });
      setTimeout(() => {
        restify.createServer = createServer;
        U.logger.info = log;
        U.logger.error = errorLog;
        model.init = modelInit;
        listen.close();

        done();
      }, 100);
    });

    it('appPath non-exists', (done) => {
      assert.throws(() => {
        rest({ configPath: `${__dirname}/app/configs` });
      }, (error) => (
        error instanceof Error && error.message === 'Lack appPath: absolute path of your app'
      ));

      done();
    });

    it('route path type error or non-exists', (done) => {
      assert.throws(() => {
        rest({
          appPath: `${__dirname}/app`,
          configPath: `${__dirname}/app/configs.js`,
          routePath: [`${__dirname}/app/route`],
        });
      }, (error) => {
        const except = 'routePath must be a string and be a existed path';
        return error instanceof Error && error.message === except;
      });

      assert.throws(() => {
        rest({
          appPath: `${__dirname}/app`,
          configPath: `${__dirname}/app/configs.js`,
          routePath: `${__dirname}/app/route`,
        });
      }, (error) => {
        const except = 'routePath must be a string and be a existed path';
        return error instanceof Error && error.message === except;
      });

      done();
    });

    it('request home /', (done) => {
      const _root = `${__dirname}/app`;
      console.error = () => {};
      U.logger.info = () => {};
      U.logger.error = () => {};

      const listen = rest({
        appPath: _root,
        middleWarePath: `${__dirname}/app/no-middle-wares`,
      }, (error) => {
        assert.equal(null, error);
        if (hasOwnProperty.call(listen, 'listening')) assert.ok(listen.listening);

        restify.createServer = createServer;
        model.init = modelInit;

        axios.get('http://127.0.0.1:8080/').then((response) => {
          try {
            assert.equal(200, response.status);
            assert.equal('OK', response.statusText);
            assert.equal('application/json; charset=utf-8', response.headers['content-type']);
            assert.equal('Hello world, I am open-rest.', response.data);
          } catch (e) {
            return done(e);
          }
          listen.close();
          U.logger.info = log;
          U.logger.error = errorLog;
          return done();
        }).catch(() => {
          listen.close();
          assert.equal(null, error);
          done();
        });
      });
    });

    it('request home / middleWareThrowError', (done) => {
      const _root = `${__dirname}/app`;
      console.error = () => {};
      U.logger.info = () => {};
      U.logger.error = () => {};

      const listen = rest({
        appPath: _root,
        middleWarePath: `${__dirname}/app/middle-wares`,
      }, (error) => {
        assert.equal(null, error);
        if (hasOwnProperty(listen, 'listening')) assert.ok(listen.listening);

        restify.createServer = createServer;
        model.init = modelInit;

        axios.get('http://127.0.0.1:8080/?middleWareThrowError=yes').catch(() => {
          listen.close();
          assert.equal(500, error.response.status);
          assert.equal('Internal Server Error', error.response.statusText);
          assert.deepEqual({
            message: 'Sorry, there are some errors in middle-ware.',
          }, error.response.data);
          done();
        });
      });
    });

    it('request /unexpetion ', (done) => {
      let listen;
      const _root = `${__dirname}/app`;
      const errorlog = console.error;
      const _done = () => {
        listen.close();
        console.error = errorlog;
        done();
      };
      U.logger.info = () => {};
      U.logger.error = () => {};
      console.error = () => {};

      listen = rest({
        appPath: _root,
        middleWarePath: `${__dirname}/app/middle-wares`,
      }, (error) => {
        assert.equal(null, error);
        if (hasOwnProperty.call(listen, 'listening')) assert.ok(listen.listening);

        restify.createServer = createServer;
        U.logger.info = log;
        U.logger.error = errorLog;
        model.init = modelInit;

        axios.get('http://127.0.0.1:8080/unexception').catch((err) => {
          assert.equal(500, error.response.status);
          assert.equal('Internal Server Error', err.response.statusText);
          assert.deepEqual({
            message: 'Ooh, there are some errors.',
          }, error.response.data);
          _done();
        });
      });
    });
  });
});
