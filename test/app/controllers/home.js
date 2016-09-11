module.exports = {
  index: function(req, res, next) {
    res.send('Hello world, I am open-rest.');
    next();
  },
  unexception: [
    function(req, res, next) {
      throw Error('Ooh, there are some errors.');
    }
  ]
};
