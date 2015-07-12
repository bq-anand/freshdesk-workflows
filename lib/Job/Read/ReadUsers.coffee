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
    @moveBatchWindow(@batchStartPage)
    @getSection()
    return # don't leak promise; use events
  moveBatchWindow: (batchStartPage) ->
    @batchStartPage = batchStartPage
    @batchEndPage = batchStartPage + @batchSize - 1
  getSection: ->
    promises = (@getPage(page) for page in [@batchStartPage..@batchEndPage])
    Promise.all(promises).bind(@)
    .catch (error) -> @emit "error", error
  getPage: (page) ->
    @binding.getUsers({page: page}).bind(@)
    .spread @readPage
    .spread (response, body) ->
      if page is @batchEndPage
        if _.isArray(body) and body.length # maybe there's something more to read
          @moveBatchWindow(@batchStartPage + @batchSize)
          @getSection()
        else # this page is empty, no need to send another batch of requests
          @emit "end"
  readPage: (response, body) ->
    @emit "data", object for object in body
    [response, body]

module.exports = ReadUsers
