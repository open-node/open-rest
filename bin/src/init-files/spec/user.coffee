data =
  name: 'MR Hello'
  email: 'xxx@qq.com'
  role: 'member'

module.exports = [{
  name: "获取用户列表"
  uri: '/users'
  expects:
    Status: 200
    JSONLength: 2
    JSONTypes: ['*', {
      id: Number
      name: String
      email: String
    }]
}, {
  name: "获取指定用户"
  uri: '/users/1'
  expects:
    Status: 200
    JSON: {
      id: 1
      name: 'Redstone Zhao'
      email: '13740080@qq.com'
      role: 'admin'
    }
}, {
  name: "修改指定用户"
  uri: '/users/1'
  verb: 'patch'
  data:
    name: 'Redstone Zhao.'
  expects:
    Status: 200
    JSON: {
      name: 'Redstone Zhao.'
      email: '13740080@qq.com'
      role: 'admin'
    }
}, {
  name: "获取修改后的指定用户"
  uri: '/users/1'
  expects:
    Status: 200
    JSON: {
      id: 1
      name: 'Redstone Zhao.'
      email: '13740080@qq.com'
      role: 'admin'
    }
}, {
  name: "添加一个用户"
  uri: '/users'
  verb: 'post'
  data: data
  expects:
    Status: 201
    JSON: data
}, {
  name: "获取刚才添加的用户"
  uri: '/users/3'
  expects:
    Status: 200
    JSON: data
}, {
  name: "再次获取用户列表, 长度为3"
  uri: '/users'
  expects:
    Status: 200
    JSONLength: 3
    JSONTypes: ['*', {
      id: Number
      name: String
      email: String
    }]
}, {
  name: "删除刚才添加的用户"
  uri: '/users/3'
  verb: 'delete'
  expects:
    Status: 204
}, {
  name: "试图获取已删除的用户会得到404错误"
  uri: '/users/3'
  expects:
    Status: 404
}, {
  name: "资源user开启了回收站功能，再次添加同样的用户，之前被删除的用户会还原"
  uri: '/users'
  verb: 'post'
  data: data
  expects:
    Status: 201
    JSON: data
}, {
  name: "已恢复的用户可以正常获取"
  uri: '/users/3'
  expects:
    Status: 200
    JSON: data
}, {
  name: "再次获取用户列表, 长度为3"
  uri: '/users'
  expects:
    Status: 200
    JSONLength: 3
    JSONTypes: ['*', {
      id: Number
      name: String
      email: String
    }]
}]
