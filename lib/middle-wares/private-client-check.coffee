utils   = require '../lib/utils'
config  = require '../config'

module.exports = (req, res, next) ->
  req._clientIp = utils.clientIp req
  req.isPrivateIp = utils.isPrivateIp req._clientIp, config.privateIps
  next()
