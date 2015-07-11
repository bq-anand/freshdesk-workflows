_ = require "underscore"

module.exports = class Worker
  constructor: (config) ->
    _.extend(@, config)
