_ = require "underscore"
Promise = require "bluebird"
Read = require "../../../core/Job/Read"

class ReadUsers extends Read
  constructor: (options) ->
    _.defaults options,
      batchSize: 10
      batchStartPage: 1
    super(options)
  run: ->
    @getSection()
  getSection: ->
    batchEndPage = @batchSize - @batchStartPage + 1
    promises = (@getPage(page) for page in [@batchStartPage..batchEndPage])
    Promise.all(promises)
  getPage: (page) ->
    @binding.getUsers({page: page})
    .bind(@)
    .spread @readPage
    .spread (response, body) ->
      if _.isArray(body) and body.length and page is @batchStartPage
        @batchStartPage += @batchSize
        @getSection()
      else
        @emit "end"
  readPage: (response, body) ->
    @emit "data", body
    [response, body]

module.exports = ReadUsers
