#!/usr/bin/env coffee

_           = require "underscore"
fs          = require "fs"

process.stdin.setEncoding('utf8')

stdin = ''
process.stdin.on('readable', ->
  chunk = process.stdin.read()
  return if chunk is null
  stdin += chunk
)

read = ->
  files = stdin.trim().split '\n'
  translations = {}
  regxps =
    hbs: [
      /{{\s*t\s(["'])([^\n]*?)\1.*}}/
      2
    ]
    coffee: [
      /\.t[\( ](['"])([^\n]*?)\1/
      2
    ]
  _.each files, (file) ->
    ext = file.split('.').pop()
    lines = fs.readFileSync(file).toString().trim().split('\n')
    return if not reg = regxps[ext]
    _.each lines, (line, lineCounter) ->
      found = line.match reg[0]
      return if not found
      key = found[reg[1]]
      return if not key
      translations[key] = [] if not translations[key]
      translations[key].push "#: #{file}: #{lineCounter + 1}"


  # Write the POT file out of the _translation hash
  outPut = ""
  _.each translations, (value, key) ->
    outPut += "#{value.join '\n'}\n"
    outPut += "msgid \"#{key.replace /"/g, '\\"'}\"\n"
    outPut += 'msgstr ""\n\n'

  process.stdout.write outPut

process.stdin.on('end', read)
