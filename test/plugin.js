const rest = require('../');
const assert = require('assert');

describe('plugin', () => {
  describe('regist and active', () => {
    it('normal', (done) => {
      let count = 2;

      const plugin1 = (openRest, path) => {
        assert.equal(rest, openRest);
        assert.equal(`${__dirname}/app`, path);
        assert.equal(2, count);
        count -= 1;
      };

      const plugin2 = (openRest, path) => {
        assert.equal(rest, openRest);
        assert.equal(`${__dirname}/app`, path);
        assert.equal(1, count);
        count -= 1;
      };

      rest.plugin(plugin1, plugin2).start(`${__dirname}/app`, (error, server) => {
        assert.equal(null, error);
        assert.ok(server);
        assert.equal(0, count);
        done();
      });
    });
  });
});

