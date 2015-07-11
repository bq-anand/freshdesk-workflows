Promise = require "bluebird"
fs = require "fs"

module.exports =
  beforeEach: ->
    binding = require "../../lib/Binding/FreshdeskBinding"
    @binding = new binding(
      credential: config.credentials.denis
    )
  "FreshdeskBinding":
    "should return users": ->
      @binding.getUsers().spread (response, body) ->
        response.statusCode.should.be.equal(200)
        body.should.be.deep.equal(require "./responses/getUsers.json")
