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
    helper.getter(Version, 'version')
    helper.assert.exists('version')
    [ # Logical or, when a function is performed by means of a stop. All failed to return to the first error.
      helper.checker.ownSelf('creatorId', 'version')
      helper.checker.sysAdmin()
    ]
    helper.version.isUsed('version', 'article')
    helper.rest.remove('version')
  ]
```

* Controller must be a function or an array

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
      comment: '文章摘要'
    contents:
      type: Sequelize.TEXT
    creatorId:
      type: Sequelize.INTEGER.UNSIGNED
      allowNull: no
  }, {
    comment: '文章版本表'
    freezeTableName: yes
    instanceMethods: {}
    classMethods: {}
  })
```
** Special Fields **
* [`createdAt`](#model-createdAt)
* [`updatedAt`](#model-updatedAt)
* [`creatorId`](#model-creatorId)
* [`clientIp`](#model-clientIp)
* [`isDelete`](#model-isDelete)

** Special Functions **
* [`unique`](#model-unique)
* [`pagination`](#model-pagination)
* [`stats`](#model-stats)
* [`sort`](#model-sort)
* [`searchCols`](#model-searchCols)
* [`writableCols`](#model-writableCols)
* [`editableCols`](#model-editableCols)
* [`onlyAdminCols`](#model-onlyAdminCols)

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

### router.get(uri, actionPath)

HTTP.verb `GET`
Equivalent to
```js
server.get(uri, function(req, res, next) {...})
```

__Arguments__
* `uri` - A route path, eg: /users/:id
* `action` - Listen method, eg: 'user#detail'.

__Example__
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
### router.put(uri, actionPath)

HTTP.verb `PUT`
Equivalent to
```js
server.put(uri, function(req, res, next) {...})
```

__Arguments__
* `uri` - A route path, eg: /users/:id
* `action` - Listen method, eg: 'user#detail'.

<a name="router-patch"></a>
### router.put(uri, actionPath)

HTTP.verb `PATCH`
Equivalent to
```js
server.patch(uri, function(req, res, next) {...})
```

__Arguments__
* `uri` - A route path, eg: /users/:id
* `action` - Listen method, eg: 'user#detail'.

<a name="router-del"></a>
### router.del(uri, actionPath)

HTTP.verb `DELETE`
Equivalent to
```js
server.del(uri, function(req, res, next) {...})
```

__Arguments__
* `uri` - A route path, eg: /users
* `action` - Listen method, eg: 'user#list'.

<a name="router-post"></a>
### router.post(uri, actionPath)

HTTP.verb `POST`
Equivalent to
```js
server.post(uri, function(req, res, next) {...})
```

__Arguments__
* `uri` - A route path, eg: /users
* `action` - Listen method, eg: 'user#add'.

<a name="router-collection"></a>
### router.collection(name, uri, parent)

HTTP.verb `POST` or `GET`
Equivalent to

router.get(uri, actionPath)
router.post(uri, actionPath)

```js
//Create a resource.
server.post(uri, function(req, res, next) {...})
//List the resource.
server.get(uri, function(req, res, next) {...})
```

__Arguments__
* `name` - Name of the resource. eq: `user`, `book`, `order`
* `uri` - Optional, A router patch.
when uri is null, uri will be /${parent}s/:${parent}Id/${name}
* `parent` - Optional, Name of the parent resource.eq: `user`, `book`

__Example____
./app/router.coffee
```js
module.exports = (r) ->
  r.collection 'book', null, 'user'
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

router.put(routePath, actionPath)
router.patch(routePath, actionPath)
router.get(routePath, actionPath)
router.del(routePath, actionPath)

```js
// Modify a resource.
server.put(routePath, function(req, res, next) {...})
server.patch(routePath, function(req, res, next) {...})
//Get a resource.
server.get(routePath, function(req, res, next) {...})
//Remove a resource.
server.del(routePath, function(req, res, next) {...})
```

__Arguments__
* `name` - Name of the resource. eq: `user`, `book`, `order`
* `routePath` - Optional, A router patch.
when routePath is null, routePath will be /${name}s/:id


<a name="router-resource"></a>
### router.model(name, routePath)

HTTP.verb `DELETE` or `GET` or `PATCH` or `PUT`
Equivalent to

router.put(routePath, actionPath)
router.patch(routePath, actionPath)
router.get(routePath, actionPath)
router.del(routePath, actionPath)

```js
// Modify a resource.
server.put(routePath, function(req, res, next) {...})
server.patch(routePath, function(req, res, next) {...})
//Get a resource.
server.get(routePath, function(req, res, next) {...})
//Remove a resource.
server.del(routePath, function(req, res, next) {...})
```

__Arguments__
* `name` - Name of the resource. eq: `user`, `book`, `order`
* `routePath` - Optional, A router patch.
when routePath is null, routePath will be /${name}s/:id




__Example____
./app/router.coffee
```js
module.exports = (r) ->
  r.collection 'book', null, 'user'
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

