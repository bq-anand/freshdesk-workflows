_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../../../../core/helper/logger"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")
Binding = require "../../../../../lib/Binding"
ReadUsers = require "../../../../../lib/Task/ActivityTask/Read/ReadUsers"

describe "ReadUsers", ->
  binding = null; logger = null; task = null;

  before ->
    binding = new Binding
      credential: settings.credentials.denis
    logger = createLogger settings.logger

  beforeEach ->
    task = new ReadUsers(
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
        sinon.spy(task.output, "write")
        sinon.spy(task.binding, "request")
        task.execute()
        .then ->
          task.binding.request.should.have.callCount(20)
          task.output.write.should.have.callCount(934)
          task.output.write.should.always.have.been.calledWithMatch sinon.match (object) ->
            object.hasOwnProperty("email")
          , "Object has own property \"email\""
        .then resolve
        .catch reject
        .finally recordingDone
