module.exports =
  before: (setupDone) ->
    nock.back.fixtures = "#{process.env.ROOT_DIR}/test/Job/Read/ReadUsersFixtures"
    setupDone()
  beforeEach: (setupDone) ->
    Freshdesk = require "../../../lib/Binding/Freshdesk"
    binding = new Freshdesk(
      credential: config.credentials.denis
    )
    ReadUsers = require "../../../lib/Job/Read/ReadUsers"
    @job = new ReadUsers(
      binding: binding
    )
    setupDone()
  "ReadUsers":
    "should exist": (testDone) ->
      nock.back "ReadUsers.json", (recordingDone) =>
        done = (error) -> recordingDone(); testDone(error)
        @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
        onData = sinon.stub()
        @job.data = {}
        @job.run()
        @job.on "data", onData
        @job.on "end", ->
          onData.should.have.callCount(934)
          onData.should.have.been.alwaysCalledWithMatch sinon.match
            email: sinon.match.string
          done()
        @job.on "error", done
