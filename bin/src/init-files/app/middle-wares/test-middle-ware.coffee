module.exports = (req, res, next) ->
  # 这是一个测试的中间件，没有任何用途，为了便于调试
  # 他会输出当前的请求url地址和时间
  console.log("#{new Date} [#{req.method}] #{req.url}")
  next()
