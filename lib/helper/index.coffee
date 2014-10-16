utils = require '../utils'

modules = {}
for file in utils.readdir(__dirname, ['coffee', 'js'], ['index'])
  moduleName = utils.file2Module file
  modules[moduleName] = require "./#{file}"

module.exports = modules
