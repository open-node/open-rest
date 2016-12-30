module.exports = {
  index: (req, res, next) => {
    res.send('Hello world, I am open-rest.');
    next();
  },
  unexception: [
    (req, res, next) => {
      setTimeout(() => {
        next(Error('Ooh, there are some errors.'));
      }, 20);
    },
  ],
};
