module.exports =
  index: (req, res, next) ->
    res.send "Hello world, now is: #{new Date}"
    next()
