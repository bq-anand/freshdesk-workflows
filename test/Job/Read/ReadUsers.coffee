module.exports =
  before: (setupDone) ->
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
    "should return users": (testDone) ->
      nock.back "Job/Read/ReadUsersFixtures/ReadUsers.json", (recordingDone) =>
        @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
        done = (error) -> recordingDone(); testDone(error)
        onData = sinon.stub()
        request = sinon.spy(@job.binding, "request")
        @job.run()
        @job.on "data", onData
        @job.on "end", ->
          try
            request.should.have.callCount(20)
            onData.should.have.callCount(934)
            onData.should.always.have.been.calledWithMatch sinon.match (object) ->
              object.hasOwnProperty("email")
            , "Object has own property \"email\""
            done()
          catch error
            done(error)
        @job.on "error", done
