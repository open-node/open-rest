# Open-rest

Standard restful api server, Base on restify and sequelize

## Installation
```bash
npm install -g open-rest
```

## Quick Start
```bash
mkdir ~/restapi && open-rest init && cd ~/restapi
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
├── cluster.coffee
├── cron.coffee
├── index.coffee
├── socket.coffee
├── LICENSE
├── package.json
└── README.md
</pre>

## Run
<pre>./index.coffee</pre>
OR
<pre>./cluster.coffee</pre>

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

The controller action is composed of a number of helper, is a control flow, each helper to achieve a single function, Helper can be reused in different controller action.


* Controller must be a function or an array

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
    # Query `version` placed on req.hooks.version
    helper.getter(Version, 'version')
    # Check if req.hooks.version exists,
    # If there is no Response will be 404 Not found, And stop to exec next step.
    helper.assert.exists('version')
    [ # Logical or, when a function is performed by means of a stop. All failed to return to the first error.
      # Check req.hooks.version.creatorId equal to req.user.id
      helper.checker.ownSelf('creatorId', 'version')
      # Check req.isAdmin is True.
      helper.checker.sysAdmin()
    ]
    # Check if the version(req.hooks.version) is being used
    helper.version.isUsed('version')
    # Remove the version (req.hooks.version), And Response output 204 Not-content.
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
* [`stats`](#utils-stats)
  * [`dimensions`](#utils-stats-dimensions)
  * [`group`](#utils-stats-group)
  * [`metrics`](#utils-stats-metrics)
  * [`filters`](#utils-stats-filters)
  * [`sort`](#utils-stats-sort)
  * [`pageParams`](#utils-stats-pageParams)
* [`nt2space`](#utils-nt2space)
* [`getToken`](#utils-getToken)
* [`getSql`](#utils-getSql)
* [`str2arr`](#utils-str2arr)
* [`searchOpt`](#utils-searchOpt)
* [`mergeSearchOrs`](#utils-mergeSearchOrs)
* [`findOptFilter`](#utils-findOptFilter)
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

<pre>GET: /routePath</pre>


__Arguments__
* `routePath` - A route path, eg: /users/:id
* `action` - Listen method, eg: 'user#detail'.

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

Equivalent to

<pre>PUT: /routePath</pre>

__Arguments__
* `routePath` - A route path, eg: /users/:id
* `action` - Listen method, eg: 'user#detail'.

<a name="router-patch"></a>
### router.patch(routePath, actionPath)

HTTP.verb `PATCH`

Equivalent to

```js
<pre>PATCH: /routePath</pre>
```

__Arguments__

* `routePath` - A route path, eg: /users/:id
* `action` - Listen method, eg: 'user#detail'.

<a name="router-del"></a>
### router.del(routePath, actionPath)

HTTP.verb `DELETE`

Equivalent to

```js
<pre>DELETE: /routePath</pre>
```

__Arguments__

* `routePath` - A route path, eg: /users
* `action` - Listen method, eg: 'user#list'.

<a name="router-post"></a>
### router.post(routePath, actionPath)

HTTP.verb `POST`

Equivalent to

<pre>POST: /routePath</pre>

__Arguments__

* `routePath` - A route path, eg: /users
* `action` - Listen method, eg: 'user#add'.

<a name="router-collection"></a>
### router.collection(name, routePath, parent)

HTTP.verb `POST` or `GET`

Equivalent to

<pre>
// List the resource
GET: /routePath
// Create a resource
POST: /routePath
</pre>

__Arguments__

* `name` - Name of the resource. eq: `user`, `book`, `order`
* `routePath` - Optional, A router patch.
when routePath is null, routePath will be /${parent}s/:${parent}Id/${name}
* `parent` - Optional, Name of the parent resource.eq: `user`, `book`

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

Equivalent to

<pre>
PUT: /routePath
PATCH: /routePath
GET: /routePath
DELETE: /routePath
</pre>

__Arguments__

* `name` - Name of the resource. eq: `user`, `book`, `order`
* `routePath` - Optional, A router patch.
when routePath is null, routePath will be /${name}s/:id


<a name="router-resource"></a>
### router.resource(name, routePath)

HTTP.verb `DELETE` or `GET` or `PATCH` or `PUT`

Equivalent to

<pre>
POST: /routePath
PUT: /routePath/:id
PATCH: /routePath/:id
GET: /routePath
GET: /routePath/:id
DELETE: /routePath/:id
</pre>

__Arguments__

* `name` - Name of the resource. eq: `user`, `book`, `order`
* `routePath` - Optional, A router patch.
when routePath is null, routePath will be /${name}s/:id

__Example__

./app/router.coffee
```js
module.exports = (r) ->
  // GET/POST: /books
  // GET/PUT/PATCH/DELETE: /books/:id
  r.resource 'book'
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

  detail: [
    ...
    ...
  ]
```

## Model

<a name="model-createdAt"></a>
### createdAt
* Auto record resource created datetime.
* Dont need to define.

<a name="model-updatedAt"></a>
### updatedAt
* Auto record resource modify datetime.
* Dont need to define.

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
    # Close auto record created datetime
    createdAt: no
    # Close auto record modify datetime
    updatedAt: no
  })
```

<a name="model-creatorId"></a>
### creatorId
* Auto record resource creator, Associated user table ID.

<a name="model-clientIp"></a>
### clientIp
* Auto record creator's ip address.

<a name="model-isDelete"></a>
### isDelete
* Mark isDelete yes when resource removed, not realy removed, only mark.

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
    # define for auto record resource creator
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # define for auto record resource creator's ip address
    clientIp:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # Mark isDelete yes when resource removed, not realy removed, only mark.
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
* With the use of `isDelete`, can achieve automatic recovery, in the use of `helper.rest.add`.

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
    # define for auto record resource creator
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # define for auto record resource creator's ip address
    clientIp:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # Mark isDelete yes when resource removed, not realy removed, only mark.
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
    includes: ['articleId', 'name']
  })
```

<a name="model-pagination"></a>
### pagination
* Define `pagination` to control pagination, in the use of `helper.rest.list`.
* pagination params is `startIndex` and `maxResults`

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
    # define for auto record resource creator
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # define for auto record resource creator's ip address
    clientIp:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # Mark isDelete yes when resource removed, not realy removed, only mark.
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
    pagination:
      maxResults: 10 // per page size default value.
      maxResultsLimit: 5000 // Max per page size.
      maxStartIndex: 500000 // Max startIndex value.
  })
```

<a name="model-sort"></a>
### sort
* Define `sort` to control order of list, in the use of `helper.rest.list`.
* Sort params is `sort` in queryString
* `sort=-date` is date desc, `sort=date` is date asc.

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
    # define for auto record resource creator
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # define for auto record resource creator's ip address
    clientIp:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
    # Mark isDelete yes when resource removed, not realy removed, only mark.
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


__Define writableCols, editableCols, onlyAdminCols example__

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
  }
```

<a name="model-searchCols"></a>
### searchCols
* 定义哪些列允许搜索的，搜索方式是怎么的，在使用 helper.rest.list 生效
* 配合 queryString 中 q, _searchs 来使用搜索功能

<a name="model-searchCols"></a>
### searchCols
* 定义哪些列允许搜索的，搜索方式是怎么的，在使用 helper.rest.list
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

