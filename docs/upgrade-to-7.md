# 从 <7 的版本升级到 >= 7 的方法

调整主要包含一下几点

* 将open-rest内置的helper全部拆分出去成为独立的npm库包，方便为何和单独升级，用户也可以自由的组合自己喜欢的helper
* 去掉一些 open-rest 原本的公共的方法，这些方法原本仅提供给 helper 用的，现在 helper 拆分出去了，自然他们也没有存在的必要。
* 删除了 ./lib/utils.writeLog 函数
* 删除了 ./lib/utils.getId 函数
* 删除了 ./lib/utils.pickParams 函数
* 删除了 ./lib/utils.stats 统计相关的对象
* 删除了 ./lib/utils.str2arr, 该用 lodash _.split
* 删除了 ./lib/utils.findOptFilter
* 删除了 ./lib/utils.searchOpt
* 删除了 ./lib/utils.mergeSearchOrs

helper 拆分出去以后的npm库包命名对应规则如下面的示例

<pre>
一下描述中出现 obj, obj1, obj2 结构如下
{
  fixed: value, // 一个固定的值
  path: 'hooks.user.id' // req 上的值的路径
}
优先获取 fixed
</pre>

* helper.rest => open-rest-helper-rest
* helper.getter => open-rest-helper-getter
* helper.params => open-rest-helper-params
* helper.assert => open-rest-helper-assert
* helper.batch => open-rest-helper-batch
* helper.console => open-rest-helper-console

helper 虽然拆分出去了，但是使用方式尽可能的保持了原来的方式，但是有些因为原来设计的不合理也有一些改进的地方，调整代码主要就是这些变化的地方


* helper.getter(Model, 'user') => helper.getter(Model, 'user', 'params.id')
* helper.getter(Model, 'user', 'userId') => helper.getter(Model, 'user', 'params.userId')
* helper.getter(Model, 'user', 'userId', 'book') => helper.getter(Model, 'user', 'hooks.book.userId')
* helper.assert.exists(hook) => helper.assert.exists(keyPath)
* helper.inArray(key1, obj1, key2, obj2, error) => helper.has(obj1, obj2, error)
* helper.equal(field, value, _obj, error) => helper.equal(keyPath, obj, erro)
* helper.notEqual(field, value, _obj, error) => helper.notEqual(keyPath, obj, erro)
* helper.rest.detail, helper.rest.add 中 attachs 参数 key => value, value 由原来的 hook 名称变为 req 上值的路径，例如原来的 {user: 'user'} 应该写成 {user: 'hooks.user'}
