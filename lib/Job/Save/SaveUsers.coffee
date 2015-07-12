_ = require "underscore"
stream = require "readable-stream"
Promise = require "bluebird"
Save = require "../../../core/Job/Save"

class SaveUsers extends Save
  constructor: (options) ->
    @stream = new stream.Readable({objectMode: true})
    super(options)
  run: ->
    while (chunk = @stream.read())
      console.log chunk
    return # don't leak promise; use events

module.exports = SaveUsers
