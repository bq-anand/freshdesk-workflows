_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createDependencies = require "../../../../../../core/helper/dependencies"
settings = (require "../../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskReadUsers = require "../../../../../../lib/Task/ActivityTask/BindingTask/Read/FreshdeskReadUsers"

describe "FreshdeskReadUsers", ->
  dependencies = createDependencies(settings)
  mongodb = dependencies.mongodb;

  Credentials = mongodb.collection("Credentials")

  task = null;

  before ->

  beforeEach ->
    task = new FreshdeskReadUsers(
      avatarId: "eeEKAkvE7ooC78P9Z"
      params: {}
    ,
      {}
    ,
      in: new stream.Readable({objectMode: true})
      out: new stream.PassThrough({objectMode: true})
    ,
      dependencies
    )
    Promise.all [
      Credentials.insert
        avatarId: "eeEKAkvE7ooC78P9Z"
        api: "Freshdesk"
        scopes: ["*"]
        details: settings.credentials["Freshdesk"]["Denis"]
    ]

  afterEach ->
    Promise.all [
      Credentials.remove()
    ]

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
