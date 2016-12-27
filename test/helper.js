const helper = require('../lib/helper');
const assert = require('assert');

describe('helper', () => {
  describe('#console', () => {
    it('console.log', (done) => {
      const _log = console.log;
      const log = helper.console.log('hello', 'world');

      console.log = (arg1, arg2) => {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, (error) => {
        assert.equal(null, error);
        console.log = _log;

        done();
      });
    });

    it('console.info', (done) => {
      const _log = console.info;
      const log = helper.console.info('hello', 'world');

      console.info = (arg1, arg2) => {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, (error) => {
        assert.equal(null, error);
        console.info = _log;

        done();
      });
    });

    it('console.error', (done) => {
      const _log = console.error;
      const log = helper.console.error('hello', 'world');

      console.error = (arg1, arg2) => {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, (error) => {
        assert.equal(null, error);
        console.error = _log;

        done();
      });
    });

    it('console.warn', (done) => {
      const _log = console.warn;
      const log = helper.console.warn('hello', 'world');

      console.warn = (arg1, arg2) => {
        assert.equal('hello', arg1);
        assert.equal('world', arg2);
      };

      log(null, null, (error) => {
        assert.equal(null, error);
        console.warn = _log;

        done();
      });
    });

    it('console.time', (done) => {
      const _log = console.time;
      const log = helper.console.time('hello');

      console.time = (arg1) => {
        assert.equal('hello', arg1);
      };

      log(null, null, (error) => {
        assert.equal(null, error);
        console.time = _log;

        done();
      });
    });

    it('console.timeEnd', (done) => {
      const _log = console.timeEnd;
      const log = helper.console.timeEnd('hello');

      console.timeEnd = (arg1) => {
        assert.equal('hello', arg1);
      };

      log(null, null, (error) => {
        assert.equal(null, error);
        console.timeEnd = _log;

        done();
      });
    });
  });
});
