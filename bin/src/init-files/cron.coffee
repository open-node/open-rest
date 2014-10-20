#! /usr/bin/env coffee

cronJob = require('cron').CronJob
moment  = require 'moment'
child   = require 'child_process'
path    = require 'path'

db      = require('./app/configs').db

BACKUPPATH = '/backup'

exec = (name, cmd, callback) ->
  callback = callback or (error, stdout, stderr) ->
    console.error error if error
    console.log "#{name} done at: #{new Date}" unless error
    console.log stdout
    console.error stderr if stderr
  child.exec cmd, {maxBuffer: 16 * 1024 * 1024}, callback

# 每个五分钟执行modification任务
new cronJob '00 */5 * * * *', ->
  exec "Modification", "#{__dirname}/bin/modification"
, (err)->
  console.error err if err
, yes

# 每隔四小时执行数据的备份任务
new cronJob '00 03 */4 * * *', ->
  sqlfile = "#{BACKUPPATH}/#{moment().format('YYYY/MM/DD/HH')}.sql"
  cmds = [
    "mkdir -p #{path.dirname sqlfile}"
  ]
  cmds.push [
    "mysqldump"
    "-h#{db.host}"
    "-u#{db.user}"
    "-p#{db.pass}" if db.pass
    "#{db.name}"
    "> #{sqlfile}"
  ].join(" ")
  exec "Backup", cmds.join(' && ')
, (err)->
  console.error err if err
, yes
