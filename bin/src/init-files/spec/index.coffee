_ = require 'underscore'

module.exports = _.flatten [
  # 默认接口测试
  require './home'

  # 测试用户的接口
  require './user'
]
