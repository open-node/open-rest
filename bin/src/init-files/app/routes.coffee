# api route 定义，之所以需要这个文件
# 是希望有一个统一的地方可以清晰的看到所有的路由配置
# 方便开发人员快速的查找定位问题

module.exports = (r) ->
  # 首页默认路由(done)
  r.get "/", "home#index"

  # 用户相关的路由(done)
  r.resource 'user'
