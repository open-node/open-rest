# Open-rest

Standard restful api server, Base on restify and sequelize

## Installation
```bash
npm install open-rest --save
```

## Quick Start
```bash
// 克隆样本功能
git clone git@github.com:open-node/open-rest-es6-boilerplate.git myApp
cd myApp

// 安装依赖库包
npm install

// 安装部署
npm run setup

```

## App directory agreement
<pre>
├── app
│   ├── configs
│   ├── controllers
│   ├── data
│   ├── lib
│   ├── locale
│   ├── middle-wares
│   ├── models
│   └── routes.coffee
├── index.js
├── socket.js
├── LICENSE
├── package.json
└── README.md
</pre>

## 请求执行顺序

# 业务逻辑之前的统一处理，比如用户身份的获取, 基础权限的判断
middle-wares

# 核心业务逻辑
controllers


## Run
./index.coffee
OR
./cluster.coffee

## Test
```bash
npm test
```

## Documentation

### Router Definition
```coffee
module.exports = (r) ->
  r.get   "/",        "controller#method"
  r.post  "/session", "user#login"
  r.del   "/session", "user#logout"
```
* [`get`](#router-get)
* [`patch`](#router-patch)
* [`put`](#router-put)
* [`post`](#router-post)
* [`del`](#router-del)
* [`collection`](#router-collection)
* [`model`](#router-model)
* [`resource`](#router-resource)

### Controller Definition

控制器模块按照约定定义在 ./controllers 目录下，每个控制器模块返回一个对象，对象的 key 是 action，值是一个函数或者一系列函数组合成的数组，每一个函数在请求的时候都会按照定义的顺序去执行


```coffee
module.exports =

  ###
  @api {DELETE} /versions/:id Remove the version when ID equal :id
  @apiName version_remove
  @apiPermission admin | owner
  @apiGroup Article
  @apiParam {Number} id verion ID
  @apiSuccessExample {json} Success-Response:
    HTTP/1.1 204 No Content
  @apiVersion 1.0.0
  ###
  remove: [
    # 根据 req.params.id 从数据库查询 version 出来，放置在 req.hooks.version 上
    helper.getter(Version, 'version')
    # 检查 req.hooks.version 是否存在，不存在则直接返回404，中断后续的 helper 方法的执行
    helper.assert.exists('version')
    [ # 这里二级数组里的方法是按照逻辑或执行的，只要有一个方法没有返回 next(error)，执行就会继续下去
      # 如果全部执行都错误了，则会返回第一次得到 error，并中断后续的 helper 方法的执行

      # 检查是否是自己的资源 req.hooks.version.creatorId 是否和 req.user.id 相等
      helper.checker.ownSelf('creatorId', 'version')

      # 检查是否是系统管理员
      helper.checker.sysAdmin()
    ]
    # 检查当前版本是否正在被使用中
    helper.version.isUsed('version')

    # 删除这个版本 (req.hooks.version), 返回 `204 Not-content`, 利用open-rest 提供的标准 helper.rest.remove
    helper.rest.remove('version')
  ]
```

### Model Definition
```coffee
module.exports = (sequelize) ->
  Version = U._.extend sequelize.define('version', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    articleId:
      type: Sequelize.INTEGER.UNSIGNED
      defaultValue: 0
    name:
      type: Sequelize.STRING(1024)
      validate:
        len: [1, 30]
    summary:
      type: Sequelize.STRING(1024)
      comment: 'Article summary'
    contents:
      type: Sequelize.TEXT
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
  }, {
    comment: 'version of article'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
  })
```
__Special Fields__
* [`createdAt`](#model-createdAt)
* [`updatedAt`](#model-updatedAt)
* [`creatorId`](#model-creatorId)
* [`clientIp`](#model-clientIp)
* [`isDelete`](#model-isDelete)

__Special Functions Config__
* [`unique`](#model-unique)
* [`pagination`](#model-pagination)
* [`sort`](#model-sort)
* [`writableCols`](#model-writableCols)
* [`editableCols`](#model-editableCols)
* [`onlyAdminCols`](#model-onlyAdminCols)
* [`allowIncludeCols`](#model-allowIncludeCols)
* [`searchCols`](#model-searchCols)
* [`stats`](#model-stats)

### lib/utils
* [`callback`](#utils-callback)
* [`intval`](#utils-intval)
* [`getModules`](#utils-getModules)
* [`pickParams`](#utils-pickParams)
* [`isPrivateIp`](#utils-isPrivateIp)
* [`remoteIp`](#utils-remoteIp)
* [`clientIp`](#utils-clientIp)
* [`realIp`](#utils-realIp)
* [`writeLog`](#utils-writeLog)
* [`readdir`](#utils-readdir)
* [`file2Module`](#utils-file2Module)
* [`getId`](#utils-getId)
* [`ucwords`](#utils-ucwords)
* [`nt2space`](#utils-nt2space)
* [`getToken`](#utils-getToken)
* [`getSql`](#utils-getSql)
* [`str2arr`](#utils-str2arr)
* [`randStr`](#utils-randStr)

###  helper/rest
* [`list`](#helper-rest-list)
* [`beforeModify`](#helper-rest-beforeModify)
* [`save`](#helper-rest-save)
* [`modify`](#helper-rest-modify)
* [`detail`](#helper-rest-detail)
* [`beforeAdd`](#helper-rest-beforeAdd)
* [`add`](#helper-rest-add)
* [`remove`](#helper-rest-remove)
* [`statistics`](#helper-rest-statistics)

### helper/getter
* [`getter`](#helper-getter)

### helper/params
* [`omit`](#helper-params-omit)
* [`required`](#helper-params-required)
* [`map`](#helper-params-map)
* [`assign`](#helper-params-assign)

### helper/assert
* [`equal`](#helper-assert-equal)
* [`notEqual`](#helper-assert-notEqual)
* [`inArray`](#helper-assert-inArray)
* [`exists`](#helper-assert-exists)

### helper/console
* [`log`](#helper-console-log)
* [`error`](#helper-console-error)
* [`info`](#helper-console-info)
* [`time`](#helper-console-time)
* [`timeEnd`](#helper-console-timeEnd)

## Router
<a name="router-get"></a>

### router.get(routePath, actionPath)

HTTP.verb `GET`

Equivalent to

GET: /routePath


__Arguments__
* `routePath` - 路由的路径，例如: `/users/:id` or `/users/:userId/books`
* `actionPath` - 监听的动作，例如：`user#detail` 表示 user 控制器模块的 detail 方法。`user#books` 表示 user 控制器模块的 books 方法

__Example__

./router.coffee
```js
module.exports = (r) ->
  // GET: /users/:id
  r.get   "/users/:id",        "user#detail"
```

./controllers/user.coffee

```js
U       = require '../lib/utils'
helper  = require '../helper'
User    = U.model('user')
module.exports =
  detail: [
    helper.getter(User, 'user', 'id')
    helper.checker.exists('user')
    helper.rest.detail('user')
  ]
```

<a name="router-put"></a>
### router.put(routePath, actionPath)

HTTP.verb `PUT`

等价于

PUT: /routePath

__Arguments__
* 同上 [`router.get`](#router-get)

<a name="router-patch"></a>
### router.patch(routePath, actionPath)

HTTP.verb `PATCH`

等价于

```js
PATCH: /routePath
```

__Arguments__
* 同上 [`router.get`](#router-get)

<a name="router-del"></a>
### router.del(routePath, actionPath)

HTTP.verb `DELETE`

等价于

```js
DELETE: /routePath
```

__Arguments__
* 同上 [`router.get`](#router-get)

<a name="router-post"></a>
### router.post(routePath, actionPath)

HTTP.verb `POST`

等价于

POST: /routePath

__Arguments__
* 同上 [`router.get`](#router-get)

<a name="router-collection"></a>
### router.collection(name, routePath, parent)

HTTP.verb `POST` or `GET`

等价于


// List the resource
GET: /routePath
// Create a resource
POST: /routePath


__Arguments__

* `name` - 资源的名称. 例如: `user`, `book`, `order`
* `routePath` - 可选参数, 路由地址, 当不设置 `routePath` 时，系统会按照约定自动计算应该的 `routePath`
* `parent` - 可选参数, 资源的父资源名称

__Example__

./app/router.coffee
```js
module.exports = (r) ->
  // GET: /users/:userId/books
  // POST: /users/:userId/books
  r.collection 'book', null, 'user'

  // GET: /books
  // POST: /books
  r.collection 'book'

  // GET: /users/book
  // POST: /users/book
  r.collection 'book', '/users/book'
```

./app/controllers/user.coffee
```js
module.exports =
  books: [
    ...
    ...
  ]

  addBook: [
    ...
    ...
  ]
```

<a name="router-model"></a>
### router.model(name, routePath)

HTTP.verb `DELETE` or `GET` or `PATCH` or `PUT`

等价于


PUT: /routePath
PATCH: /routePath
GET: /routePath
DELETE: /routePath


__Arguments__

* `name` - 资源的名称. 例如: `user`, `book`, `order`
* `routePath` - 可选参数, 路由地址, 当不设置 `routePath` 时，系统会按照约定自动计算应该的 `routePath`

__Example__

./app/router.coffee
```js
module.exports = (r) ->
  // GET/PUT/PATCH/DELETE: /books/:id
  r.model 'book'

  // GET/PUT/PATCH/DELETE: /users/books/:id
  r.model 'book', '/users/books/:id'
```

./app/controllers/book.coffee
```js
module.exports =
  detail: [
    ...
    ...
  ]
  modify: [
    ...
    ...
  ]
  remove: [
    ...
    ...
  ]
```


<a name="router-resource"></a>
### router.resource(name, routePath)

HTTP.verb `DELETE` or `GET` or `PATCH` or `PUT`

等价于


POST: /routePath
PUT: /routePath/:id
PATCH: /routePath/:id
GET: /routePath
GET: /routePath/:id
DELETE: /routePath/:id


__Arguments__

* `name` - 资源的名称. 例如: `user`, `book`, `order`
* `routePath` - 可选参数, 路由地址, 当不设置 `routePath` 时，系统会按照约定自动计算应该的 `routePath`

__Example__

./app/router.coffee
```js
module.exports = (r) ->
  // GET/POST: /books
  // GET/PUT/PATCH/DELETE: /books/:id
  r.resource 'book'

  // GET/POST: /books
  // GET/PUT/PATCH/DELETE: /users/books/:id
  r.resource 'book', '/users/books'
```

./app/controllers/book.coffee
```js
module.exports =
  add: [
    ...
    ...
  ]

  list: [
    ...
    ...
  ]

  modify: [
    ...
    ...
  ]

  remove: [
    ...
    ...
  ]

  detail: [
    ...
    ...
  ]
```

## Model

<a name="model-createdAt"></a>
### createdAt
* 自动记录资源创建的时间
* 不需要单独去定义字段

<a name="model-updatedAt"></a>
### updatedAt
* 自动记录资源最后更新的时间
* 不需要单独去定义字段

__Close createdAt or updatedAt example__
```coffee
module.exports = (sequelize) ->
  Version = U._.extend sequelize.define('version', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    articleId:
      type: Sequelize.INTEGER.UNSIGNED
      defaultValue: 0
    name:
      type: Sequelize.STRING(1024)
      validate:
        len: [1, 30]
    summary:
      type: Sequelize.STRING(1024)
      comment: 'Article summary'
    contents:
      type: Sequelize.TEXT
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
  }, {
    comment: 'version of article'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
    # 关闭 createdAt
    createdAt: no
    # 关闭 updatedAt
    updatedAt: no
  })
```

<a name="model-creatorId"></a>
### creatorId
* 自动记录资源的创建者，使用约定的 req.user.id, 这个规则只在您通过 open-rest 标准的添加 helper `helper.rest.add` 才会生效
* 字段需要定义，如果不定义则没有此功能

<a name="model-clientIp"></a>
### clientIp
* 自动记录资源创建者的ip地址，使用的是 `utils.clientIp`, 同上这个规则只在您通过 open-rest 标准的添加 helper `helper.rest.add` 才会生效
* 字段需要定义，如果不定义则没有此功能

<a name="model-isDelete"></a>
### isDelete
* 标记是否已删除，这个功能是为了避免用户误操作导致恢复数据成本过高而设计的，这个预定只在您通过 open-rest 标准的删除 helper `helper.rest.remove` 才会生效
* 字段需要定义，如果不定义则没有此功能

__Define creatorId, clientIp, isDelete  example__

```coffee
module.exports = (sequelize) ->
  Version = U._.extend sequelize.define('version', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    articleId:
      type: Sequelize.INTEGER.UNSIGNED
      defaultValue: 0
    name:
      type: Sequelize.STRING(1024)
      validate:
        len: [1, 30]
    summary:
      type: Sequelize.STRING(1024)
      comment: 'Article summary'
    contents:
      type: Sequelize.TEXT
    # 自动记录创建者 req.user.id
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # 自动记录创建者的 id 地址，utils.clientIp(req)
    clientIp:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # 是否在 helper.rest.remove 的时候仅标记 isDelete
    isDelete:
      type: Sequelize.ENUM
      values: ['yes', 'no']
      defaultValue: 'no'
  }, {
    comment: 'version of article'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
  })
```

<a name="model-unique"></a>
### unique
* 配合 `isDelete` 使用，能自动恢复已删除的数据，在使用 open-rest 标准添加 helper `helper.rest.add` 的时候

__Define isDelete unique example__

```coffee
module.exports = (sequelize) ->
  Version = U._.extend sequelize.define('version', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    articleId:
      type: Sequelize.INTEGER.UNSIGNED
      defaultValue: 0
    name:
      type: Sequelize.STRING(1024)
      validate:
        len: [1, 30]
    summary:
      type: Sequelize.STRING(1024)
      comment: 'Article summary'
    contents:
      type: Sequelize.TEXT
    # 是否在 helper.rest.remove 的时候仅标记 isDelete
    isDelete:
      type: Sequelize.ENUM
      values: ['yes', 'no']
      defaultValue: 'no'
  }, {
    comment: 'version of article'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
  }, {
    # 当添加的资源 `articleId` 以及 `name` 和某个已删除的资源的 `articleId`, `name` 一致的时候，已删除的资源会被恢复为正常状态(`isDelete`='no')
    includes: ['articleId', 'name']
  })
```

<a name="model-pagination"></a>
### pagination
* 定义 `pagination` 来控制分页，在使用 open-rest 标准列表 helper `helper.rest.list` 时
* 分页的参数通过 queryString 中的 `startIndex` 和 `maxResults` 分别代表返回列表的起始序号和最多的条目数

__Define pagination example__

```coffee
module.exports = (sequelize) ->
  Version = U._.extend sequelize.define('version', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    articleId:
      type: Sequelize.INTEGER.UNSIGNED
      defaultValue: 0
    name:
      type: Sequelize.STRING(1024)
      validate:
        len: [1, 30]
    summary:
      type: Sequelize.STRING(1024)
      comment: 'Article summary'
    contents:
      type: Sequelize.TEXT
  }, {
    comment: 'version of article'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
  }, {
    pagination:
      maxResults: 10 // 默认每页多少条
      maxResultsLimit: 5000 // 最大每页多少条
      maxStartIndex: 500000 // 分页开始的最大值
  })
```

<a name="model-sort"></a>
### sort
* 定义 `sort` 来控制列表功能的排序，当使用 open-rest 标准列表helper `helper.rest.list` 时
* 排序参数通过 queryString 中的 sort 来指定
* `sort=-date` 使用日期 `date` 降序排列, `sort=date` 使用日期 `date` 升序排列

__Define sort example__

```coffee
module.exports = (sequelize) ->
  Version = U._.extend sequelize.define('version', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    articleId:
      type: Sequelize.INTEGER.UNSIGNED
      defaultValue: 0
    name:
      type: Sequelize.STRING(1024)
      validate:
        len: [1, 30]
    summary:
      type: Sequelize.STRING(1024)
      comment: 'Article summary'
    contents:
      type: Sequelize.TEXT
  }, {
    comment: 'version of article'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
  }, {
    sort:
      default: 'id' // 使用 `help.params.list` 时，如果用户没有指定排序方式则采用 id 升序排列
      allow: ['id', 'expiresAt', 'updatedAt', 'createdAt'] // 定义允许排序的字段
  })
```

<a name="model-writableCols"></a>
### writableCols
* 定义一个数组，用来指定添加时哪些字段是允许用户自行指定的，在使用 helper.rest.add 时生效

<a name="model-editableCols"></a>
### editableCols
* 定义一个数组，用来指定编辑时哪些字段是允许用户自行指定的，在使用 helper.rest.modify 时生效
* 如果没有定义此值则使用 writableCols 设置

<a name="model-onlyAdminCols"></a>
### onlyAdminCols
* 定义一个数组，用来指定添加或编辑时哪些字段只允许管理员指定，在使用 helper.rest.modify, helper.rest.add 时生效

<a name="model-allowIncludeCols"></a>
### allowIncludeCols
* 定义一个数组，用来指定当资源被其他资源包含的时候（include）的时候那些列可以被查询返回，常见于 User 中，User 会被其他资源包含，但是 User 里的某些列需要隐藏，例如： password, email 等

__Define writableCols, editableCols, onlyAdminCols allowIncludeCols example__

```coffee
module.exports = (sequelize) ->
  User = U._.extend sequelize.define('user', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    name:
      type: Sequelize.STRING
      allowNull: no
      set: (val) -> @setDataValue 'name', U.nt2space(val)
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
    writableCols: [
      'email', 'name', 'status', 'role', 'switchs'
    ]
    editableCols: [
      'name', 'name', 'status', 'switchs', 'role'
    ]
    # `role` `status`, `switchs` 这三个字段只有管理员可以操作
    onlyAdminCols: [
      'role', 'status', 'switchs'
    ]
    # 当 `user` 被其他资源包含的时候仅返回 `id`, `name`, `status` 三个字段，其余的不返回
    allowIncludeCols: ['id', 'name', 'status']
  }
```

<a name="model-searchCols"></a>
### searchCols
* 定义哪些列允许搜索的，搜索方式是怎么的，在使用 helper.rest.list 生效
* 配合 queryString 中 q, _searchs 来使用搜索功能

<a name="model-stats"></a>
### stats
* 定义统计相关的配置，在使用 helper.rest.statistics 时生效
* 统计功能使用 queryString 中的一下参数
  * `dimensions` 统计的维度，多个用逗号隔开
  * `metrics` 统计的指标，多个用逗号隔开
  * `sort` 结果的排序方式，用法类似于 list 中的 sort, `sort=-count` 按 count 降序，`sort=date` 按 count 升序
  * `filters` 过滤条件，对 dimensions 或者metrics的过滤

__Define searchCols, stats example__

```coffee
module.exports = (sequelize) ->
  User = U._.extend sequelize.define('user', {
    id:
      type: Sequelize.INTEGER.UNSIGNED
      primaryKey: yes
      autoIncrement: yes
    name:
      type: Sequelize.STRING
      allowNull: no
      set: (val) -> @setDataValue 'name', U.nt2space(val)
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
    writableCols: [
      'email', 'name', 'status', 'role', 'switchs'
    ]
    editableCols: [
      'name', 'name', 'status', 'switchs', 'role'
    ]
    # `role` `status`, `switchs` 这三个字段只有管理员可以操作
    onlyAdminCols: [
      'role', 'status', 'switchs'
    ]
    searchCols:
      # 定义允许name字段搜索，搜索的方式为 LIKE 匹配
      name:
        op: 'LIKE'
        match: "%{1}%"
      # 定义允许email字段搜索，搜索的方式为 LIKE 匹配
      email:
        op: 'LIKE'
        match: "%{1}%"
    stats:
      # 定义有哪些维度
      dimensions:
        # 日期维度，及计算方式
        date: 'DATE(`user`.`createdAt`)'
        # 状态维度，及计算方式
        status: '`user`.`status`'
      # 定义有哪些指标
      metrics:
        # 总数指标以及计算方式
        count: 'COUNT(`user`.`id`)'
        # 状态正常的数量以及计算方式
        enableds: "SUM(IF(`user`.`status`='enabled', 1, 0))"
        # 禁用用户的数量以及计算方式
        disableds: "SUM(IF(`user`.`status`='disabled', 1, 0))"
  }
```

## lib/utils

<a name="utils-callback"></a>
### utils.callback(Promise instance, callback)

__Arguments__
* `Promise` - 符合 pormise 风格的对象
* `callback` - 传统的 callback, 第一个参数是 error 对象, 后面的参数是结果

__Example__

```js
U = require('./utils');
module.exports = function(id, callback) {
  // 等价于
  // U.model('user').findById(id).then(function(user) {
  //   callback(null, user);
  // }).catch(callback);
  U.callback(U.model('user').findById(id), callback);
```

<a name="utils-intval"></a>
### utils.intval(value)
* 将一个变量强制转换为整数类型

__Arguments__
* `value` - 一个数字

__Example__
```js
U = require('./utils');
U.intval(3232); // 返回 3232
U.intval('3232'); // 返回 3232
U.intval('3232abc'); // 返回 3232
U.intval('-3232abc'); // 返回 -3232
U.intval('-3232.12'); // 返回 -3232
```

<a name="utils-getModules"></a>
### utils.getModules(path)
* 根据路径获取该路径下的所有模块，并且以模块名为key

__Arguments__
* `path` 要读取的目录地址


<a name="utils-pickParams"></a>
### utils.pickParams(req, cols, Model)
* 从 web 请求的 req 中提取用户提交的值

__Arguments__
* `req` web 请求的 request 对象
* `cols` 要获取用户指定的值 key 的列表
* `Model` 关联的 Model 的定义

__Return__
* 返回一个对象，key 为字段名称，value是用户指定的值

<a name="utils-isPrivateIp"></a>
### utils.isPrivateIp(ip, whiteList)
* 判断一个 ip 是否是私有客户端, 返回布尔类型

__Arguments__
* `ip` 要判断的 IP 地址
* `whiteList` 指定的白名单

<a name="utils-remoteIp"></a>
### utils.remoteIp(req)
* 根据 web 请求的 request 对象获取真实的连接 ip 地址, 这个是直接连接的 ip 地址, 如果您用了 nginx 做代理转发，那么这个地址就是您 nginx 服务器的地址

<a name="utils-clientIp"></a>
### utils.clientIp(req)
* 根据 web 请求的 request 对象获取客户的 ip 地址, 这个地址是最有可能造价的，获取的是 HTTP 头信息的 `x-forwarded-for`

<a name="utils-realIp"></a>
### utils.realIp(req, proxyIps)
* 根据 web 请求的 request 对象获取客户的 ip 地址, 这个地址如果真实连接 ip 是在允许的 proxyIps 内，则返回的是 HTTP 头信息的 `x-real-ip` 否则返回的是 remoteIp

__remoteIp, clientIp, realIp 的差异__
* `remoteIp` 是最真实的物理连接直接过来的地址，不可以模拟，但是只要请求经过中间层转发，例如nginx转发，或者使用了cdn加速后得到的地址并非原始发起请求的客户地址
* `clientIp` 直接获取的 HTTP 头信息的 `x-forwarded-for`, 所以可以轻易的模拟，但是这个值却最有可能是原始发起请求的客户端的地址。这个地址可以做一些简单的记录，但是不能做了为私有客户端ip的判断依据
* `realIp` 获取的是 HTTP 头信息的 `x-real-ip`, 当 remoteIp 是被设定为 proxyIps 的请求下，这个是一个约定的规则，只要控制好当前web服务不能直接被外部访问到，并且对定允许代理该服务的地址，必须要把头信息 `x-real-ip` 设置为连接其的 `remoteIp`

<a name="utils-writeLog"></a>
### utils.writeLog(file, msg)
* 往指定路径的文件写入日志，如果文件不存在则创建文件，以及文件所在的路径(只能创建一级), 如果文件存在则追加内容在末尾

<a name="utils-readdir"></a>
### utils.readdir(dir, exts = 'coffee', excludes = 'index')
* 从一个目录中读取所有的文件名出来

__Arguments__
* `dir` 要读取的目录地址
* `exts` 要读取的文件后缀，多个用数组指定, 默认为 `coffee`
* `excludes` 要获取的文件名，多个用数组指定, 默认为 `index`

<a name="utils-file2Module"></a>
### utils.file2Module(filename)
* 将文件名称转换成模块的名称，文件名多个单词用中划线(-)隔开, 模块名是驼峰式命名

<a name="utils-getId"></a>
### utils.getId(req, id, obj)
* 从 hooks 获取 params 上获取某个值

__Example__
```js
U = require('./lib/utils');
U.getId(req, 'id'); // 返回 req.params.id
U.getId(req, 'name'); // 返回 req.params.name
U.getId(req, 'id', 'user'); // 返回 req.hooks.user.id
U.getId(req, 'name', 'user'); // 返回 req.hooks.user.name
```

<a name="utils-ucwords"></a>
### utils.ucwords(str)
* 输入的字符串将其首字母大写返回
* 如果输入的不是字符串，则直接返回本身

__Example__
```js
U = require('./lib/utils');
U.ucwords(222); // 返回 222
U.ucwords([222]); // 返回 [222]
U.ucwords('hello'); // 返回 'Hello'
U.ucwords('222'); // 返回 '222'
```

<a name="utils-nt2space"></a>
### utils.nt2space(str)
* 将输入的字符串中的制表符、换行符替换为单个空格
* 如果输入的不是字符串，则直接返回本身

<a name="utils-getToken"></a>
### utils.getToken(req)
* 从 web 请求的 request 对象中获取 token
* 约定的优先级如下
  * req.headers['x-auth-token']
  * req.params.access_token
  * req.params.accessToken

<a name="utils-str2arr"></a>
### utils.str2arr(str, spliter, maxLen)
* 将指定的 `str` 用 `spliter` 切割成数组
* 如果设置了 `maxLen` 会限制返回的数组的最大长度，超出的部分会忽略掉

<a name="utils-randStr"></a>
### utils.randStr(len, type)
* 返回指定长度 `len` 的随机字符串

__Arguments__
* `len` 随机字符串的长度
* `type` 随即字符串的类型, 可选 `noraml` or `strong`，默认是 `noraml`

##  helper/rest

<a name="helper-rest-list"></a>
### helper.rest.list(Model, opt = null, allowAttrs, hook = null)
* 标准的 list 方法
* 默认会排除 isDelete=yes 的资源，如果要查看全部资源请使用 showDelete=yes 来显示

__Arguments__
* `Model` 要查询的资源 Model 定义
* `opt` 可选参数，指定 option 的位置 req.hooks[option] 指定 option 就不会通过 Model.findAllOpts(req.params) 来计算 option 了。
* `allowAttrs` 可选参数，允许返回的属性，不指定则返回全部属性
* `hook` 可选参数，如果指定则从数据库查询出来的数据会放置在 req.hooks[hook] 上，而非直接 res.send 出去

<a name="helper-rest-beforeModify"></a>
### helper.rest.beforeModify(Model, hook, cols)
* 修改资源之前的操作，会把修改的部分都赋值上去，但是不会保存

__Arguments__
* `Model` 要操作的资源 Model 定义
* `hook` 资源所在位置 req.hooks[hook]
* `cols` 可选参数，资源允许修改的字段，不填会选用 `Model.editableCols` 或 `Model.writableCols`

<a name="helper-rest-save"></a>
### helper.rest.save(Model, hook)
* 修改资源 `rest.beforeModify` 之后的操作，会把变化保存到数据库

__Arguments__
* `Model` 要操作的资源 Model 定义
* `hook` 资源所在位置 req.hooks[hook]

<a name="helper-rest-modify"></a>
### helper.rest.modify(Model, hook, cols)
* 标准的修改资源的方法，`helper.rest.beforeModify` 和 `helper.rest.save` 的组合

__Arguments__
* `Model` 要操作的资源 Model 定义
* `hook` 资源所在位置 req.hooks[hook]
* `cols` 可选参数，资源允许修改的字段，不填会选用 `Model.editableCols` 或 `Model.writableCols`

<a name="helper-rest-detail"></a>
### helper.rest.detail(hook, attachs = null, statusCode = 200, attrFilter = true)
* 标准的输出资源的方法

__Arguments__
* `hook` 资源所在位置 req.hooks[hook]
* `attachs` 可选参数，要附加到资源上的对象 例如: {"user": "user", "book": "userBook"}，会把 `req.hooks` 上的 `user` 以及 `userBook` 附加到资源的 `user` 和 `book` 上
* `statusCode` 可选参数, 指定返回的`http.header.statusCode`, 默认值为 `200`
* `attrFilter` 可选参数，是否通过 req.params.attrs 过滤结果，默认值为 `true` 过滤

<a name="helper-rest-beforeAdd"></a>
### helper.rest.beforeAdd(Model, cols, hook = Model.name)
* 标准的添加资源前的方法，会自动处理 `isDelete`，`unique` 来确定是真实添加一条数据还是恢复一条已删除的数据, 只添加不输出

__Arguments__
* `Model` 要操作的资源 Model 定义
* `cols` 可选参数，资源允许修改的字段，不填会选用 `Model.editableCols` 或 `Model.writableCols`
* `hook` 可选参数，资源所在位置 `req.hooks[hook]`, 默认为 `Model.name`

<a name="helper-rest-add"></a>
### helper.rest.add(Model, cols, hook = Model.name, attachs = null)
* 标准的添加资源前的方法，`helper.rest.beforeAdd` 和 `helper.rest.detail` 的组合

__Arguments__
* `Model` 要操作的资源 Model 定义
* `cols` 可选参数，资源允许修改的字段，不填会选用 `Model.editableCols` 或 `Model.writableCols`
* `hook` 可选参数，资源所在位置 `req.hooks[hook]`, 默认为 `Model.name`
* `attachs` 可选参数，要附加到资源上的对象 例如: {"user": "user", "book": "userBook"}，会把 `req.hooks` 上的 `user` 以及 `userBook` 附加到资源的 `user` 和 `book` 上

<a name="helper-rest-remove"></a>
### helper.rest.remove(hook)
* 标准的删除的方法, 会自动处理 `isDelete`, 如果定义了 `isDelete` 字段，则不会真实删除数据，仅标记当前数据的 `isDelete` = `yes`

__Arguments__
* `hook` 资源所在位置 `req.hooks[hook]`

## helper-getter

<a name="helper-getter"></a>
### helper.getter(Model, hook, id = 'id', obj = null)
* 标准的从数据库某表获取一条记录的操作

__Arguments__
* `Model` 要操作的资源 Model 定义
* `hook` 获取到的资源放置在何处 `req.hooks[hook]`
* `id` 可选参数，获取 `id` 的名称, 默认值为 id
* `obj` 可选参数，获取 `id` 的对象, 不填的时候从 req.params 上获取, 如果设置了则从 req.hooks[obj] 上获取

## helper/params

<a name="helper-params-omit"></a>
### helper.params.omit(key1, key2, key3, ...)
* 从 `req.params` 上删除掉某些参数

__Arguments__
* `key1` 要删除掉的参数名称
* `key2` 第二个要删除的参数名称，后续以此类推

<a name="helper-params-required"></a>
### helper.params.required(keys)
* 在 `req.params` 上验证某些参数是否存在, 主要用在验证必选参数, 如果缺少某些参数，则返回 `409`

__Arguments__
* `keys` 要验证的名称，数组类型

<a name="helper-params-map"></a>
### helper.params.map(dict)
* 将 `req.params` 根据指定的字典做映射转换

__Arguments__
* `dict` `source => target` 结构对象，`source`，`target` 均为字符串

<a name="helper-params-assign"></a>
### helper.params.assign(key, value)
* 将 `req.params` 根据指定的 `key` 赋值为 `value`

__Arguments__
* `key` 要赋值的参数名称
* `value` 要赋值的值

## helper/assert

<a name="helper-assert-equal"></a>
### helper.assert.equal(field, value, obj, error)
* 用来判断某个值是否和指定的值相等，不等则输出错误

__Arguments__
* `field` 要判断的键名
* `value` 要比较的静态的值, 不能是引用
* `obj` 要判断的对象，默认是 `req.params`, 如果制定了 `obj` 则为: `req.hooks[obj]`
* `error` 如果不相等，输出的错误信息, String 类型或者 Error 类型

<a name="helper-assert-notEqual"></a>
### helper.assert.notEqual(field, value, obj, error)
* 用来判断某个值是否和指定的值不相等，相等则输出错误, 这个和 `helper.assert.equal` 刚好相反

__Arguments__
* `field` 要判断的键名
* `value` 要比较的静态的值, 不能是引用
* `obj` 要判断的对象，默认是 `req.params`, 如果制定了 `obj` 则为: `req.hooks[obj]`
* `error` 如果相等，输出的错误信息, String 类型或者 Error 类型

<a name="helper-assert-inArray"></a>
### helper.assert.inArray(field1, obj1, field2, obj2, error)
* 用来判断某个值是否和某个值所包含，不包含则输出错误, 利用 `field1`, `obj1` 找到一个值 `val1`，判断是否在 `field2`, `obj2` 指定的变量 `val2` 中, 使用 `[val2].indexOf(val1) > -1 ` 判断， 如果 `val2` 是字符串，会使用逗号 `,` 切割

__Arguments__
* `field1` 要判断的键名
* `obj1` 要判断的对象，默认是 `req.params`, 如果制定了 `obj` 则为: `req.hooks[obj]`
* `field2` 要比较的静态的值, 不能是引用
* `obj2` 要判断的对象，默认是 `req.params`, 如果制定了 `obj` 则为: `req.hooks[obj]`
* `error` 如果不包含，输出的错误信息, String 类型或者 Error 类型

<a name="helper-assert-exists"></a>
### helper.assert.exists(hook, error)
* 验证 `req.hooks` 上某个键名是否存在，不存在则输出错误

__Arguments__
* `hook` 要验证的变量 req.hooks[hook]
* `error` 可选参数，如果不存在，输出的错误信息, String 类型或者 Error 类型, 默认值为 error.notFound()

## helper/console

<a name="helper-console-log"></a>
### helper.console.log(variable, ...)
* 和 `console.log` 用法类似，只是在请求的时候触发, 这一系列的 helper 都用来调试, 在控制器方法数组的第一级使用不影响 API 的行为, 如果在二级数组使用会影响 API 的行为，因为二级数组是逻辑或的关系，只要有一个执行成功就会通过，而 `helper.console` 这个系列的执行都是可以通过的

<a name="helper-console-error"></a>
### helper.console.error(variable, ...)
* 类似与 `console.error`

<a name="helper-console-info"></a>
### helper.console.info(variable, ...)
* 类似与 `console.info`

<a name="helper-console-time"></a>
### helper.console.time(key)
* 类似与 `console.time`

<a name="helper-console-timeEnd"></a>
### helper.console.time(key)
* 类似与 `console.timeEnd`

### Contributing
- Fork this repo
- Clone your repo
- Install dependencies
- Checkout a feature branch
- Feel free to add your features
- Make sure your features are fully tested
- Open a pull request, and enjoy <3

### MIT license
Copyright (c) 2016 Open-node
Author Redstone Zhao
Email: 13740080@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the &quot;Software&quot;), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

