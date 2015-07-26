_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../../../../core/helper/logger"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")
FreshdeskBinding = require "../../../../../lib/FreshdeskBinding"
FreshdeskReadUsers = require "../../../../../lib/Task/ActivityTask/Read/FreshdeskReadUsers"

describe "FreshdeskReadUsers", ->
  binding = null; logger = null; task = null;

  before ->
    binding = new FreshdeskBinding
      credential: settings.credentials.denis
    logger = createLogger settings.logger

  beforeEach ->
    task = new FreshdeskReadUsers(
      params: {}
    ,
      {}
    ,
      in: new stream.Readable({objectMode: true})
      out: new stream.PassThrough({objectMode: true})
      binding: binding
      logger: logger
    )

  it "should run", ->
    @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
    new Promise (resolve, reject) ->
      nock.back "test/fixtures/FreshdeskReadUsers/normal.json", (recordingDone) ->
        sinon.spy(task.out, "write")
        sinon.spy(task.binding, "request")
        task.execute()
        .then ->
          task.binding.request.should.have.callCount(20)
          task.out.write.should.have.callCount(934)
          task.out.write.should.always.have.been.calledWithMatch sinon.match (object) ->
            object.hasOwnProperty("email")
          , "Object has own property \"email\""
        .then resolve
        .catch reject
        .finally recordingDone
