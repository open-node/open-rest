module.exports = function(Models) {
  Models.user.belongsTo(Models.team)
  Models.team.belongsTo(Models.user, {
    as: 'owner',
    foreignKey: 'ownerId'
  });
};
