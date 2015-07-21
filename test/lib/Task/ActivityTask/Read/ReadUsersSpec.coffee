Promise = require "bluebird"
stream = require "readable-stream"
Binding = require "../../../../../lib/Binding"
ReadUsers = require "../../../../../lib/Task/ActivityTask/Read/ReadUsers"

describe "ReadUsers", ->
  job = null; binding = null;

  beforeEach ->
    binding = new Binding(
      credential: config.credentials.denis
    )
    job = new ReadUsers(
      {}
    ,
      binding: binding
      input: new stream.Readable({objectMode: true})
      output: new stream.PassThrough({objectMode: true})
    )

  it "should run", ->
    @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
    new Promise (resolve, reject) ->
      nock.back "test/fixtures/ReadUsersNormalOperation.json", (recordingDone) ->
        sinon.spy(job.output, "write")
        sinon.spy(job.binding, "request")
        job.execute()
        .then ->
          job.binding.request.should.have.callCount(20)
          job.output.write.should.have.callCount(934)
          job.output.write.should.always.have.been.calledWithMatch sinon.match (object) ->
            object.hasOwnProperty("email")
          , "Object has own property \"email\""
        .then resolve
        .catch reject
        .finally recordingDone
