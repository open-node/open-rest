#!/usr/bin/env bash
find ../app -type f | ./read.coffee > locale/application.pot
msgmerge -UN --no-wrap ./locale/en.po ./locale/application.pot
msgmerge -UN --no-wrap ./locale/zh.po ./locale/application.pot

