fs    = require "fs"
_     = require "underscore"
exec  = require('child_process').exec

module.exports = (dirname, type = 'coffee') ->
  cmd = [
    "cp -r #{__dirname}/init-files/* #{dirname}"
    "mv #{dirname}/gitignore #{dirname}/.gitignore"
    "cd #{dirname}/app/configs"
    "cp ./config.default.coffee ./config.development.coffee"
    "cp ./config.default.coffee ./config.production.coffee"
    "cp ./config.default.coffee ./config.apitest.coffee"
  ]
  if type is 'js'
    cmd.push "coffee -c `find #{dirname} -type f -name '*.coffee'`"
    cmd.push "rm `find #{dirname} -type f -name '*.coffee'`"

  cmd.push "cd #{dirname}"
  cmd.push "npm install"

  command = cmd.join(' && ')
  exec command, (err, stdout, stderr) ->
    throw err if err
    console.log stdout if stdout
    console.error stderr if stderr
