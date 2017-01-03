# Open-rest

Standard restful api server, Base on restify and sequelize

[![Build status](https://api.travis-ci.org/open-node/open-rest.svg?branch=master)](https://travis-ci.org/open-node/open-rest)
[![codecov](https://codecov.io/gh/open-node/open-rest/branch/master/graph/badge.svg)](https://codecov.io/gh/open-node/open-rest)

## Node version
<pre> >= 6 </pre>


## Installation
```bash
npm install open-rest --save
```

## Usage
```javascript
const rest = require('open-rest');

rest.start(`${__dirname}/app', (error, server) => {
  if (error) {
    console.error(error);
    process.exit();
  }
  console.log(`Service started at: ${new Date()}`);
});
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
│   └── routes.js
├── index.js
├── LICENSE
├── package.json
└── README.md
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
Copyright (c) 2017 Open-node
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

