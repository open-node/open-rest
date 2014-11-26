Sequelize   = require('sequelize').Sequelize
_           = require 'underscore'
ModelBase   = require './base'

module.exports = (sequelize) ->
  User = _.extend sequelize.define('user', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    name:
      type: Sequelize.STRING
      allowNull: no
      validate:
        len: [2, 30]
    role:
      type: Sequelize.ENUM
      values: ['member', 'admin']
      allowNull: no
      defaultValue: 'member'
    email:
      unique: yes
      type: Sequelize.STRING
      allowNull: no
      validate:
        isEmail: yes
      comment: '用户email地址'
    status:
      type: Sequelize.ENUM
      values: ['enabled', 'disabled']
      defaultValue: 'enabled'
      allowNull: no
    language:
      type: Sequelize.STRING
      defaultValue: 'zh'
      allowNull: no
      comment: '当前用户的语言设置'
    isDelete:
      type: Sequelize.ENUM
      values: ['yes', 'no']
      defaultValue: 'no'
      allowNull: no
      comment: '是否被删除'
  }, {
    comment: '系统用户表'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
  }), ModelBase, {
    unique: ['email']
    sort:
      default: 'id'
      allow: ['id', 'name', 'email', 'status', 'updatedAt', 'createdAt']
    # 创建或者编辑的时候允许的字段
    # 如果不指定 editableCos 则 editableCos 等于 writableCols
    writableCols: [
      'email', 'name', 'status', 'role', 'language'
    ]
    # 只有管理员才可以修改的字段
    onlyAdminCols: ['email', 'role', 'status']
  }
