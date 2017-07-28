module.exports = {
  log(...args) {
    return (req, res, next) => {
      console.log(...args);
      next();
    };
  },

  error(...args) {
    return (req, res, next) => {
      console.error(...args);
      next();
    };
  },

  info(...args) {
    return (req, res, next) => {
      console.info(...args);
      next();
    };
  },

  warn(...args) {
    return (req, res, next) => {
      console.warn(...args);
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
