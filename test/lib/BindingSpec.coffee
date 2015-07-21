Binding = require "../../lib/Binding"
settings = (require "../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

describe "Binding", ->
  binding = null

  beforeEach ->
    binding = new Binding(
      credential: settings.credentials.denis
    )

  it "binding.getUsers() :: GET /contacts.json", (testDone) ->
    nock.back "test/fixtures/Binding/getUsers.json", (recordingDone) =>
      binding.getUsers().spread (response, body) ->
        # check body before response to make the test runner show more info in case of an error
        body.should.be.an("array")
        body.length.should.be.equal(50)
        body.should.all.have.property("email")
        response.statusCode.should.be.equal(200)
      .finally recordingDone # use .finally to propagate exceptions (.then swallows them)
      .nodeify testDone

#  it "binding should report rate limiting errors @ratelimit", (testDone) ->
#    binding
#    testDone()
#
