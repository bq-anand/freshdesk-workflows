_ = require "underscore"
stream = require "readable-stream"
Match = require "mtr-match"
Job = require "../Job"
Read = require "./Read"
Save = require "./Save"

class Download extends Job
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      read: Read
      save: Save
    save.input = read.output = new stream.PassThrough({objectMode: true})
    super
  run: ->
    @read.run()
    @save.run()

module.exports = Download
