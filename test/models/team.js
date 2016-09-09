var Sequelize   = require('sequelize')
  , _           = require('lodash');

module.exports = function(sequelize) {
  return _.extend(sequelize.define('team', {
    id: {
      type: Sequelize.INTEGER.UNSIGNED,
      primaryKey: true,
      autoIncrement: true
    },
    name: {
      type: Sequelize.STRING(30),
      allowNull: true,
      validate: {
        len: [0, 30],
      }
    },
    ownerId: Sequelize.INTEGER.UNSIGNED
  }), {
    includes: {
      owner: 'user',
      book: ['book', false]
    }
  });
};
