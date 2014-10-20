#!/usr/bin/env coffee

_           = require "underscore"
fs          = require "fs"

po2json = (str) ->
  translate = {}
  regxp = /\nmsgid "([^\n]+)"\nmsgstr "([^\n]+)"/g
  str.replace regxp, (txt, key, value) ->
    translate[key] = value
  JSON.stringify translate

write = (poFile, lang, destFile) ->
  destFile = "../locale/#{lang}.js" if not destFile
  str = fs.readFileSync(poFile).toString()
  json = po2json(str)
  fs.writeFileSync(destFile, "module.exports = {\"#{lang}\":#{json}};")

write.apply null, process.argv.slice 2
