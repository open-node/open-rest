# 这个 helper 复刻 console 的功能

module.exports =
  log: (msg) ->
    (req, res, next) ->
      console.log(msg)
      next()

  log: (msg) ->
    (req, res, next) ->
      console.error(msg)
      next()

  info: (msg) ->
    (req, res, next) ->
      console.info(msg)
      next()

  time: (key) ->
    (req, res, next) ->
      console.time(key)
      next()

  timeEnd: (key) ->
    (req, res, next) ->
      console.timeEnd(key)
      next()
