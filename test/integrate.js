const rest = require('../');
const _ = require('lodash');
const axios = require('axios');
const assert = require('assert');
const restify = require('restify');
const U = require('../lib/utils');

describe('integrate', () => {
  describe('#un-init', () => {
    it('check type', (done) => {
      assert.ok(rest instanceof Object);
      assert.ok(rest.start instanceof Function);
      assert.ok(rest.plugin instanceof Function);
      assert.equal(rest.plugin(), rest);
      assert.equal(U, rest.utils);
      assert.ok(rest.Router);
      assert.ok(rest.helper);
      assert.ok(rest.errors);
      assert.ok(rest.restify);

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
        'Router', 'helper', 'utils',
        'errors', 'restify',
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

    restify.createServer = (option) => {
      assert.equal('open-rest', option.name);
      assert.equal('1.0.0', option.version);

      return createServer.call(restify, option);
    };

    it('argument all right', (done) => {
      U.logger.info = () => {};
      U.logger.error = () => {};

      const listen = rest.start(`${__dirname}/app`, (error, server) => {
        assert.equal(null, error);
        assert.ok(server);
        restify.createServer = createServer;
        U.logger.info = log;
        U.logger.error = errorLog;
        listen.close();

        done();
      });
    });

    it('request home /', (done) => {
      console.error = () => {};
      U.logger.info = () => {};
      U.logger.error = () => {};

      const listen = rest.start(`${__dirname}/app`, (error, server) => {
        assert.equal(null, error);
        assert.ok(server);
        restify.createServer = createServer;
        U.logger.info = log;
        U.logger.error = errorLog;
        assert.equal(null, error);

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
      const listen = rest.start(`${__dirname}/app`, (error, server) => {
        assert.equal(null, error);
        assert.ok(server);
        console.error = () => {};
        U.logger.info = () => {};
        U.logger.error = () => {};

        restify.createServer = createServer;
        assert.equal(null, error);

        restify.createServer = createServer;

        axios.get('http://127.0.0.1:8080/?middleWareThrowError=yes').catch((err) => {
          U.logger.info = log;
          U.logger.error = errorLog;
          listen.close();
          assert.equal(500, err.response.status);
          assert.equal('Internal Server Error', err.response.statusText);
          assert.deepEqual({
            message: 'Sorry, there are some errors in middle-ware.',
          }, err.response.data);
          done();
        });
      });
    });

    it('request /unexpetion ', (done) => {
      const errorlog = console.error;
      U.logger.info = () => {};
      U.logger.error = () => {};
      console.error = () => {};

      const listen = rest.start(`${__dirname}/app`, (error, server) => {
        assert.equal(null, error);
        assert.ok(server);
        const _done = () => {
          U.logger.info = log;
          U.logger.error = errorLog;
          listen.close();
          console.error = errorlog;
          done();
        };

        restify.createServer = createServer;
        assert.equal(null, error);
        restify.createServer = createServer;

        axios.get('http://127.0.0.1:8080/unexception').catch((err) => {
          assert.equal(500, err.response.status);
          assert.equal('Internal Server Error', err.response.statusText);
          assert.deepEqual({
            message: 'Ooh, there are some errors.',
          }, err.response.data);
          _done();
        });
      });
    });

    it('request /unexpetion server uncaughtException', (done) => {
      const errorlog = console.error;
      U.logger.info = () => {};
      U.logger.error = () => {};
      console.error = () => {};

      const listen = rest.start(`${__dirname}/app`, (error, server) => {
        assert.equal(null, error);
        assert.ok(server);
        const _done = () => {
          U.logger.info = log;
          U.logger.error = errorLog;
          listen.close();
          console.error = errorlog;
          done();
        };

        const req = {};
        const res = {
          finished: false,
          send: (statusCode, txt) => {
            assert.equal(500, statusCode);
            assert.equal('Internal error', txt);
            _done();
          },
        };
        const router = {};
        const err = new Error('There are some errors');

        restify.createServer = createServer;
        assert.equal(null, error);
        restify.createServer = createServer;
        server.emit('uncaughtException', req, res, router, err);
      });
    });

    it('request /unexpetion server uncaughtException', (done) => {
      const listen = rest.start(`${__dirname}/app`, (error, server) => {
        assert.equal(null, error);
        assert.ok(server);
        const req = {};
        const res = { finished: true };
        const router = { name: 'This is router' };
        const err = new Error('There are some errors');

        restify.createServer = createServer;
        assert.equal(null, error);
        restify.createServer = createServer;
        server.emit('uncaughtException', req, res, router, err);
      });
      const errorlog = console.error;
      U.logger.info = () => {};
      U.logger.error = (route, error) => {
        assert.deepEqual({ name: 'This is router' }, route);
        assert.deepEqual(new Error('There are some errors'), error);

        U.logger.info = log;
        U.logger.error = errorLog;
        listen.close();
        console.error = errorlog;
        done();
      };
      console.error = () => {};
    });

    it('listen there are some error', (done) => {
      restify.createServer = (option) => {
        assert.equal('open-rest', option.name);
        assert.equal('1.0.0', option.version);

        const server = createServer.call(restify, option);

        server.listen = (port, ip, callback) => {
          callback(new Error('There is an error when listen'));
        };
        return server;
      };
      rest.start(`${__dirname}/app`, (error, server) => {
        assert.ok(server);
        assert.ok(error);
        assert.deepEqual(new Error('There is an error when listen'), error);
        restify.createServer = createServer;
        done();
      });
    });
  });
});
