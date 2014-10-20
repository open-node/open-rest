fs    = require "fs"
_     = require "underscore"
exec  = require('child_process').exec

module.exports = (dirname, type = 'coffee') ->
  cmd = [
    "cp -r #{__dirname}/init-files/* #{dirname}"
  ]
  if type is 'js'
    cmd.push "coffee -c `find #{dirname} -type f -name '*.coffee'`"
    cmd.push "rm `find #{dirname} -type f -name '*.coffee'`"

  command = cmd.join(' && ')
  console.log command
  exec command, (err, stdout, stderr) ->
    throw err if err
    console.log stdout if stdout
    console.error stderr if stderr
