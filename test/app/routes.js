module.exports = function(r) {
  r.get('/', 'home#index');
  r.get('/unexception', 'home#unexception');
};
