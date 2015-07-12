stream = require "readable-stream"

module.exports =
  beforeEach: (setupDone) ->
    Freshdesk = require "../../../lib/Binding/Freshdesk"
    binding = new Freshdesk(
      credential: config.credentials.denis
    )
    ReadUsers = require "../../../lib/Job/Read/ReadUsers"
    @job = new ReadUsers(
      binding: binding
      stream: new stream.Writable()
    )
    setupDone()
  "ReadUsers":
    "should exist": (testDone) ->
      nock.back "ReadUsers.json", (recordingDone) =>
        @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
        onData = sinon.stub()
        @job.data = {}
        @job.run()
        @job.on "data", onData
        @job.on "end", ->
          onData.should.have.callCount(10)
          onData.should.have.been.alwaysCalledWithMatch sinon.match
            email: sinon.match.string
          recordingDone()
          testDone()
        @job.on "error", (error) ->
          recordingDone()
          testDone(error)

      # data listener should.be.called
