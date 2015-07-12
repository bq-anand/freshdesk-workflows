_ = require "underscore"
Promise = require "bluebird"
Read = require "../../../core/Job/Read"

class ReadUsers extends Read
  constructor: (options) ->
    _.defaults options,
      chapterSize: 10
      chapterStart: 1
    @chapterPromises = []
    super(options)
  run: ->
    @jumpToChapter(@chapterStart)
    @readChapter()
    return # don't leak promise; use events
  readChapter: ->
    promises = @getChapterPromises()
    promises[promises.length - 1] = promises[promises.length - 1].spread (response, body) ->
      if _.isArray(body) and body.length # the last page of current chapter was full of data, so we should read next chapter
        @jumpToChapter(@chapterStart + @chapterSize)
        @readChapter()
      else
        @end()
    @chapterPromises.push(
      Promise.all(promises).bind(@)
    )
  end: ->
    Promise.all(@chapterPromises).bind(@)
    .then -> @emit "end"
    .catch (error) -> @emit "error", error
  jumpToChapter: (chapterStart) ->
    @chapterStart = chapterStart
    @chapterEnd = chapterStart + @chapterSize - 1
  getChapterPromises: ->
    @readPage(page) for page in [@chapterStart..@chapterEnd]
  readPage: (page) ->
    @binding.getUsers({page: page}).bind(@)
    .spread (response, body) ->
      @emit "data", object for object in body
      [response, body]

module.exports = ReadUsers
