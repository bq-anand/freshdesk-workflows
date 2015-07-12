# can't use "mocha --grep @binding" along with "--watch"
# mocha picks up all tests after watch cycle (even those that are supposed to be filtered out)
#return unless process.env.TEST_BINDINGS

module.exports =
  before: (setupDone) ->
    nock.back.fixtures = "#{process.env.ROOT_DIR}/test/Binding/FreshdeskFixtures"
    setupDone()
  beforeEach: (setupDone) ->
    Freshdesk = require "../../lib/Binding/Freshdesk"
    @binding = new Freshdesk(
      credential: config.credentials.denis
    )
    setupDone()
  "Binding":
    "@binding.getUsers() :: GET /contacts.json": (testDone) ->
      nock.back "getUsers.json", (recordingDone) =>
        @binding.getUsers().spread (response, body) ->
          # check body before response to make the test runner show more info in case of an error
          body.should.be.an("array")
          body.length.should.be.equal(50)
          body.should.all.have.property("email")
          response.statusCode.should.be.equal(200)
          return
        .finally recordingDone # use .finally to propagate exceptions (.then swallows them)
        .then testDone
        .catch testDone
    "@binding should report rate limiting errors @ratelimit": (testDone) ->
      @binding
      testDone()

