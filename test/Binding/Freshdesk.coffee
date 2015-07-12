Promise = require "bluebird"
fs = require "fs"
nock = require "nock"
nock.back.fixtures = "#{process.env.CWD or process.cwd()}/test/Binding/fixtures"

# can't use "mocha --grep @binding" along with "--watch"
# mocha picks up all tests after watch cycle (even those that are supposed to be filtered out)
#return unless process.env.TEST_BINDINGS

module.exports =
  beforeEach: ->
    Freshdesk = require "../../lib/Binding/Freshdesk"
    @binding = new Freshdesk(
      credential: config.credentials.denis
    )
  "Binding":
    "@binding.getUsers() :: GET /contacts.json": (done) ->
      nock.back "getUsers.json", (nockbackDone) =>
        @binding.getUsers().spread (response, body) ->
          # check body before response to make the test runner show more info in case of an error
          body.should.be.an("array")
          body.length.should.be.equal(50)
          body.should.all.have.property("email")
          response.statusCode.should.be.equal(200)
          return
        .finally nockbackDone # use .finally to propagate exceptions (.then swallows them)
        .then done
        .catch done
    "@binding should report rate limiting errors @ratelimit": ->
      @binding

