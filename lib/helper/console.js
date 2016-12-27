const apply = Function.prototype.apply;

module.exports = {
  log(...args) {
    return (req, res, next) => {
      apply.call(console.log, console, args);
      next();
    };
  },

  error(...args) {
    return (req, res, next) => {
      apply.call(console.error, console, args);
      next();
    };
  },

  info(...args) {
    return (req, res, next) => {
      apply.call(console.info, console, args);
      next();
    };
  },

  warn(...args) {
    return (req, res, next) => {
      apply.call(console.warn, console, args);
      next();
    };
  },

  time(key) {
    return (req, res, next) => {
      console.time(key);
      next();
    };
  },

  timeEnd(key) {
    return (req, res, next) => {
      console.timeEnd(key);
      next();
    };
  },
};
