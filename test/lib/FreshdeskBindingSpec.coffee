_ = require "underscore"
Promise = require "bluebird"
MemoryLeakTester = require "../../core/lib/MemoryLeakTester"
settings = (require "../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/test.json")

FreshdeskBinding = require "../../lib/FreshdeskBinding"

describe "FreshdeskBinding", ->
  @timeout(10000) if process.env.NOCK_BACK_MODE is "record"

  binding = null

  beforeEach ->
    binding = new FreshdeskBinding({scopes: ["*"]})
    binding.setCredential(
      details: settings.credentials["Freshdesk"]["Generic"]
    )

  it "binding.getUsers() :: GET /contacts.json @fast", ->
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

  it "shouldn't leak memory @slow", ->
    @timeout(60000)
    tester = new MemoryLeakTester(
      runner: ->
        new Promise (resolve, reject) ->
          nock.back "test/fixtures/FreshdeskBinding/getUsers.json", (recordingDone) ->
            binding.getUsers()
            .spread (response, body) ->
              should.exist(response)
              should.exist(body)
            .then resolve
            .catch reject
            .finally recordingDone
    )
    tester.execute()
