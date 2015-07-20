stream = require "readable-stream"
Binding = require "../../../../lib/Binding"
ReadUsers = require "../../../../lib/Job/Read/ReadUsers"

describe "ReadUsers", ->
  job = null; binding = null;

  beforeEach (setupDone) ->
    binding = new Binding(
      credential: config.credentials.denis
    )
    job = new ReadUsers(
      binding: binding
      input: new stream.Readable({objectMode: true})
      output: new stream.PassThrough({objectMode: true})
    )
    setupDone()

  it "should run", (testDone) ->
    nock.back "test/fixtures/ReadUsersNormalOperation.json", (recordingDone) =>
      @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
      done = (error) -> recordingDone(); testDone(error)
      onData = sinon.stub()
      request = sinon.spy(job.binding, "request")
      job.output.on "data", (chunk) ->
        onData(chunk) if chunk
      job.output.on "end", ->
        try
          request.should.have.callCount(20)
          onData.should.have.callCount(934)
          onData.should.always.have.been.calledWithMatch sinon.match (object) ->
            object.hasOwnProperty("email")
          , "Object has own property \"email\""
          done()
        catch error
          done(error)
      job.output.on "error", done
      job.run()
