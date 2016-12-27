const rest = require('../');
const assert = require('assert');

describe('process', () => {
  describe('#event rejection-handled', () => {
    it('trigger regjection-handled', (done) => {
      const p = new Promise((resolve, reject) => {
        setTimeout(() => {
          reject(new Error('sss'));
        }, 10);
      });

      rest.utils.logger.error = (promise) => {
        if (!(promise instanceof Promise)) return;
        promise.catch((error) => {
          try {
            assert.equal('sss', error.message);
            assert.ok(error instanceof Error);
          } catch (e) {
            return done(e);
          }
          return done();
        });
      };

      setTimeout(() => {
        p.then(() => {});
      }, 20);
    });
  });
});
