_ = require "underscore"
stream = require "readable-stream"
Match = require "mtr-match"

class Job
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      input: Match.Where (stream) -> Match.test(stream.read, Function) # stream.Readable or stream.Duplex
      output: Match.Where (stream) -> Match.test(stream.write, Function) # stream.Writable or stream.Duplex
    _.extend(@, options)

  run: -> throw new Error("Implement me!")

module.exports = Job
