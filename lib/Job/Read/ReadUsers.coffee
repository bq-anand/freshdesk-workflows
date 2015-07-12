_ = require "underscore"
Promise = require "bluebird"
Read = require "../../../core/Job/Read"

class ReadUsers extends Read
  constructor: (options) ->
    _.defaults options,
      chapterSize: 10
      chapterStart: 1
    super(options)
  run: ->
    @chapterPromises = []
    @isErrorEmitted = false
    @jumpToChapter(@chapterStart)
    @readChapter()
    return # don't leak promise; use events
  readChapter: ->
    promises = @getChapterPromises()
    promises[0] = promises[0].spread (response, body) ->
      return @end() if @isErrorEmitted
      if _.isArray(body) and body.length # the last page of current chapter was full of data, so we should read next chapter
        @jumpToChapter(@chapterStart + @chapterSize)
        @readChapter()
      else
        @end()
    @chapterPromises.push(
      Promise.all(promises).bind(@)
      .catch (error) ->
        @isErrorEmitted = true
        @emit "error", error # we may emit "error" multiple times
    )
  end: ->
    Promise.all(@chapterPromises).bind(@)
    .finally -> @emit "end" if not @isErrorEmitted
    return # break infinite loop
  jumpToChapter: (chapterStart) ->
    @chapterStart = chapterStart
    @chapterEnd = chapterStart + @chapterSize - 1
  getChapterPromises: ->
    @readPage(page) for page in [@chapterEnd..@chapterStart] # reverse order, for faster feedback on whether we should read the next chapter
  readPage: (page) ->
    @binding.getUsers({page: page}).bind(@)
    .spread (response, body) ->
      @emit "data", object for object in body
      [response, body]


module.exports = ReadUsers
