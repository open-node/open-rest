var rest      = require('../')
  , assert    = require('assert');

describe('process', function() {

  describe('#event rejection-handled', function() {

    it('trigger regjection-handled', function(done) {

      var loggerError = rest.utils.logger.error;
      var p = new Promise(function(resolve, reject){
        setTimeout(function(){
          reject(new Error("sss"))
        }, 10)
      })

      rest.utils.logger.error = function(p) {
        if (!(p instanceof Promise)) return;
        p.catch(function(error) {
          try {
            assert.equal('sss', error.message);
            assert.ok(error instanceof Error);
          } catch(e) {
            return done(e);
          }
          done();
        });
      };

      setTimeout(function(){
        p.then(function(){
        })
      }, 20);

    });

  });

});
