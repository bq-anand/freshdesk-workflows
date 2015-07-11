_ = require "underscore"
Promise = require "bluebird"
requestAsync = Promise.promisify(require "request")

module.exports = class Binding
  constructor: (config) ->
    _.extend(@, config)
  request: (options) ->
    requestAsync(options)
