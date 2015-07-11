_ = require "underscore"
{EventEmitter} = require "events"

class Job extends EventEmitter
  constructor: (options) ->
    _.extend(@, options)
  run: -> throw "Implement \"run\" method"

module.exports = Job
