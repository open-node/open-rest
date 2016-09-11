module.exports = [
  function(req, res, next) {
    req._middleWare = 'This is the first middleWare.';
    next();
  }
]
