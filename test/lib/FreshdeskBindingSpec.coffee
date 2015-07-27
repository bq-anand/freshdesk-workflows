_ = require "underscore"
Promise = require "bluebird"
FreshdeskBinding = require "../../lib/FreshdeskBinding"
settings = (require "../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

describe "FreshdeskBinding", ->
  @timeout(10000) if process.env.NOCK_BACK_MODE is "record"

  binding = null

  beforeEach ->
    binding = new FreshdeskBinding({scopes: ["*"]})
    binding.setCredential(
      details: settings.credentials["Freshdesk"]["Denis"]
    )

  it "binding.getUsers() :: GET /contacts.json", ->
    new Promise (resolve, reject) ->
      nock.back "test/fixtures/FreshdeskBinding/getUsers.json", (recordingDone) ->
        binding.getUsers()
        .spread (response, body) ->
          # check body before response to make the test runner show more info in case of an error
          body.should.be.an("array")
          body.length.should.be.equal(50)
          body.should.all.have.property("email")
          response.statusCode.should.be.equal(200)
        .then resolve
        .catch reject
        .finally recordingDone # use .finally to propagate exceptions (.then swallows them)

#  it "binding should report rate limiting errors @ratelimit", (testDone) ->
#    binding
#    testDone()
#
