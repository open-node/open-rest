module.exports = [
  (req, res, next) => {
    req._middleWare = 'This is the first middleWare.';
    if (req.params.middleWareThrowError) {
      throw Error('Sorry, there are some errors in middle-ware.');
    }
    next();
  },
];
