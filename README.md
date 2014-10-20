## open-rest ![NPM version](https://img.shields.io/npm/v/open-rest.svg?style=flat)

Standard rest server, Base on restify and sequelize

### Installation
```bash
$ npm install open-rest
```

### Example
```js
var openRest = require('open-rest');
openRest.initialize(__dirname + '/app');
```

### App directory agreement
<pre>
├── app // 所有跟 webservice 直接相关的用户的程序文件，均在这里
│   ├── configs // 存放 配置文件
│   ├── controllers // 存放控制器文件
│   ├── data // 存放应用需要用到的某些固定数据
│   ├── lib // 存放一些公用的程序文件, 例如 ./utils.coffee
│   ├── locale // 存放 i18n, L10n 的一些文件
│   ├── middle-wares // 存放中间件程序文件
│   ├── models // 存放 model 的定义文件
│   └── routes.coffee // 存放路由初始化函数
├── cluster.coffee // 多核启动脚本
├── cron.coffee // 计划任务启动脚本
├── index.coffee // 单核启动脚本
├── LICENSE // LICENSE 文件
├── package.json // 项目管理信息
└── README.md // 说明文档
</pre>

### Contributing
- Fork this repo
- Clone your repo
- Install dependencies
- Checkout a feature branch
- Feel free to add your features
- Make sure your features are fully tested
- Open a pull request, and enjoy <3

### MIT license
Copyright (c) 2014 Redstone Zhao

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

