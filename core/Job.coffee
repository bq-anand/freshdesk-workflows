_ = require "underscore"
stream = require "readable-stream"
Match = require "mtr-match"

class Job
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      input: stream.Readable
      output: stream.Writable
    _.extend(@, options)
  run: -> throw "Implement \"run\" method"

module.exports = Job
