var slice = [].slice;

module.exports = {

  log: function() {
    var args = slice.call(arguments, 0);
    return function(req, res, next) {
      console.log.apply(console, args);
      return next();
    };
  },

  error: function(msg) {
    var args = slice.call(arguments, 0);
    return function(req, res, next) {
      console.error.apply(console, args);
      return next();
    };
  },

  info: function(msg) {
    var args = slice.call(arguments, 0);
    return function(req, res, next) {
      console.info.apply(console, args);
      return next();
    };
  },

  warn: function(msg) {
    var args = slice.call(arguments, 0);
    return function(req, res, next) {
      console.warn.apply(console, args);
      return next();
    };
  },

  time: function(key) {
    return function(req, res, next) {
      console.time(key);
      return next();
    };
  },

  timeEnd: function(key) {
    return function(req, res, next) {
      console.timeEnd(key);
      return next();
    };
  }

};
