_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../../../../core/helper/logger"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")
Binding = require "../../../../../lib/Binding"
ReadUsers = require "../../../../../lib/Task/ActivityTask/Read/ReadUsers"

describe "ReadOrders", ->
  job = null; binding = null;

  beforeEach ->
    job = new ReadOrders(
      params:
        datestart: "09/10/2013"
        dateend: "09/15/2013"
    , _.extend dependencies(),
        input: new stream.Readable({objectMode: true})
        output: new stream.PassThrough({objectMode: true})
    )

describe "ReadUsers", ->
  binding = null; logger = null; job = null;

  before ->
    binding = new Binding
      credential: settings.credentials.denis
    logger = createLogger settings.logger

  beforeEach ->
    job = new ReadUsers(
      params: {}
    ,
      input: new stream.Readable({objectMode: true})
      output: new stream.PassThrough({objectMode: true})
      binding: binding
      logger: logger
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
