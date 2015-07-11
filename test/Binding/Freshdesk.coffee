Promise = require "bluebird"
fs = require "fs"

# can't use "mocha --grep @binding" along with "--watch"
# mocha picks up all tests after watch cycle (even those that are supposed to be filtered out)
return unless process.env.TEST_BINDINGS

module.exports =
  beforeEach: ->
    Freshdesk = require "../../lib/Binding/Freshdesk"
    @binding = new Freshdesk(
      credential: config.credentials.denis
    )
  "Binding":
    "@binding.getUsers() :: GET /contacts.json": ->
      @binding.getUsers().spread (response, body) ->
        # check body before response to make the test runner show more info in case of an error
        body.should.be.deep.equal(require "./responses/getUsers.json")
        response.statusCode.should.be.equal(200)
    "@binding should report rate limiting errors @ratelimit": ->
      @binding

