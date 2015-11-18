assert      = require 'assert'
stats       = require '../lib/stats'


describe 'stats', ->

  describe 'metrics', ->
    it "no", (done) ->
      Model =
        stats:
          dimensions:
            date: '`date2`'
      params = {}
      expected = undefined
      assert.throws ->
        stats.metrics(Model, params)
      , Error
      done()

    it "single", (done) ->
      Model =
        stats:
          metrics:
            count: 'count(*)'
            total: 'SUM(`num`)'
      params =
        metrics: 'total'
      expected = ["SUM(`num`) AS `total`"]
      assert.deepEqual stats.metrics(Model, params), expected
      done()

    it "multi", (done) ->
      Model =
        stats:
          metrics:
            count: 'count(*)'
            total: 'SUM(`num`)'
      params =
        metrics: 'count,total'
      expected = ["count(*) AS `count`", "SUM(`num`) AS `total`"]
      assert.deepEqual stats.metrics(Model, params), expected
      done()

    it "non-allowd", (done) ->
      Model =
        stats:
          metrics:
            count: 'count(*)'
            total: 'SUM(`num`)'
      params =
        metrics: 'avg'
      assert.throws ->
        stats.metrics(Model, params)
      , Error
      done()

  describe 'dimension', ->
    it "no", (done) ->
      Model =
        stats:
          dimensions:
            date: '`date2`'
      params = {}
      expected = undefined
      assert.equal stats.dimensions(Model, params), expected
      done()

    it "single", (done) ->
      Model =
        stats:
          dimensions:
            date: '`date2`'
      params =
        dimensions: 'date'
      expected = ["`date2` AS `date`"]
      assert.deepEqual stats.dimensions(Model, params), expected
      done()

    it "multi", (done) ->
      Model =
        stats:
          dimensions:
            date: '`date2`'
            network: '3 + 2'
      params =
        dimensions: 'date,network'
      expected = ["`date2` AS `date`", "3 + 2 AS `network`"]
      assert.deepEqual stats.dimensions(Model, params), expected
      done()

    it "non-allowd", (done) ->
      Model =
        stats:
          dimensions:
            date: '`date2`'
            network: '3 + 2'
      params =
        dimensions: 'date,network,name'
      assert.throws ->
        stats.dimensions(Model, params)
      , Error
      done()

  describe 'filters', ->
    it "no", (done) ->
      Model =
        rawAttributes: {}
        stats:
          dimensions:
            date: '`date2`'
      params = {}
      expected = {}
      assert.deepEqual stats.filters(Model, params.filters), expected
      done()

    it "include isDelete column", (done) ->
      Model =
        rawAttributes:
          isDelete: {}
        stats:
          dimensions:
            date: '`date2`'
      params = {}
      expected = {}
      assert.deepEqual stats.filters(Model, params.filters), expected
      done()

    it "single", (done) ->
      Model =
        rawAttributes: {}
        stats:
          dimensions:
            date: '`date2`'
      filters = 'date==2014'
      expected = {"`date2`": $or: [$eq: '2014']}
      assert.deepEqual stats.filters(Model, filters), expected
      done()

    it "multi", (done) ->
      Model =
        rawAttributes:
          networkId: {}
        stats:
          dimensions:
            date: '`date2`'
            network: '3 + 2'
      filters = 'date==2014;networkId==11'
      expected =
        "`date2`": $or: [$eq: '2014']
        "networkId": $or: [$eq: '11']
      assert.deepEqual stats.filters(Model, filters), expected
      done()

    it "non-allowd", (done) ->
      Model =
        rawAttributes:
          networkId: {}
        stats:
          dimensions:
            date: '`date2`'
            network: '3 + 2'
      filters = 'date==2014;networkId==11;name=niubi'
      assert.throws ->
        stats.filters(Model, filters)
      , Error
      done()

    it "need escape", (done) ->
      Model =
        rawAttributes:
          networkId: {}
        stats:
          dimensions:
            date: '`date2`'
            network: '3 + 2'
      filters = "date==2014';networkId==11"
      expected =
        "`date2`": $or: [$eq: "2014'"]
        "networkId": $or: [$eq: '11']
      assert.deepEqual stats.filters(Model, filters), expected
      done()

    it "no simple", (done) ->
      Model =
        rawAttributes:
          networkId: {}
        stats:
          dimensions:
            date: '`date2`'
            network: '3 + 2'
      filters = "date==2014,date==2015;networkId==11,networkId==23"
      expected =
        "`date2`": $or: [{$eq: '2014'}, {$eq: '2015'}]
        "networkId": $or: [{$eq: '11'}, {$eq: '23'}]
      assert.deepEqual stats.filters(Model, filters), expected
      done()

  describe 'sort', ->

    it "no set", (done) ->
      params =
        dimensions: 'date,network,creator'
        metrics: 'count,avg,total'
      expected = undefined
      assert.equal stats.sort({}, params), expected
      done()

    it "desc", (done) ->
      params =
        dimensions: 'date,network,creator'
        metrics: 'count,avg,total'
        sort: '-count'
      expected = "count DESC"
      assert.equal stats.sort({}, params), expected
      done()

    it "asc", (done) ->
      params =
        dimensions: 'date,network,creator'
        metrics: 'count,avg,total'
        sort: 'count'
      expected = "count ASC"
      assert.equal stats.sort({}, params), expected
      done()

  describe 'pageParams', ->

    it "default no set", (done) ->
      Model =
        stats: {}
      params = {}
      expected = [0, 10]
      assert.deepEqual stats.pageParams(Model, params), expected
      done()

    it "noraml page", (done) ->
      Model =
        stats: {}
      params =
        startIndex: 20
        maxResults: 15
      expected = [20, 15]
      assert.deepEqual stats.pageParams(Model, params), expected
      done()

    it "set pagination default", (done) ->
      Model =
        stats:
          pagination:
            maxResults: 20
            maxResultsLimit: 2000
            maxStartIndex: 50000
      params = {}
      expected = [0, 20]
      assert.deepEqual stats.pageParams(Model, params), expected
      done()

    it "set pagination default page", (done) ->
      Model =
        stats:
          pagination:
            maxResults: 20
            maxResultsLimit: 2000
            maxStartIndex: 50000
      params =
        startIndex: 50
      expected = [50, 20]
      assert.deepEqual stats.pageParams(Model, params), expected
      done()

    it "set pagination limit startIndex", (done) ->
      Model =
        stats:
          pagination:
            maxResults: 20
            maxResultsLimit: 2000
            maxStartIndex: 50000
      params =
        startIndex: 5000000
      expected = [50000, 20]
      assert.deepEqual stats.pageParams(Model, params), expected
      done()

    it "set pagination limit maxResults", (done) ->
      Model =
        stats:
          pagination:
            maxResults: 20
            maxResultsLimit: 2000
            maxStartIndex: 50000
      params =
        startIndex: 5000000
        maxResults: 10000
      expected = [50000, 2000]
      assert.deepEqual stats.pageParams(Model, params), expected
      done()
