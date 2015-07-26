_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../../../../core/helper/logger"
createKnex = require "../../../../../core/helper/knex"
createBookshelf = require "../../../../../core/helper/bookshelf"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskBinding = require "../../../../../lib/FreshdeskBinding"
FreshdeskDownloadUsers = require "../../../../../lib/Task/ActivityTask/Download/FreshdeskDownloadUsers"
createFreshdeskUser = require "../../../../../lib/Model/FreshdeskUser"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskDownloadUsers", ->
  binding = null; knex = null; bookshelf = null; logger = null; FreshdeskUser = null; task = null; # shared between tests

  before (beforeDone) ->
    knex = createKnex settings.knex
    bookshelf = createBookshelf knex
    logger = createLogger settings.logger
    FreshdeskUser = createFreshdeskUser bookshelf
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> FreshdeskUser.createTable()
    .nodeify beforeDone

  after (teardownDone) ->
    knex.destroy()
    .nodeify teardownDone

  beforeEach ->
    binding = new FreshdeskBinding(
      credential: settings.credentials.denis
    )
    task = new FreshdeskDownloadUsers(
      FreshdeskReadUsers:
        input:
          avatarId: "wuXMSggRPPmW4FiE9"
          params: {}
      FreshdeskSaveUsers:
        input:
          avatarId: "wuXMSggRPPmW4FiE9"
          params: {}
    ,
      {}
    ,
      in: new stream.PassThrough({objectMode: true})
      out: new stream.PassThrough({objectMode: true})
      binding: binding
      bookshelf: bookshelf
      logger: logger
    )

  it "should run", ->
    new Promise (resolve, reject) ->
      nock.back "test/fixtures/FreshdeskReadUsers/normal.json", (recordingDone) ->
        task.execute()
        .then ->
          knex(FreshdeskUser::tableName).count("id")
          .then (results) ->
            results[0].count.should.be.equal("934")
        .then ->
          FreshdeskUser.where({email: "a.sweno@hotmail.com"}).fetch()
          .then (model) ->
            should.exist(model)
            model.get("email").should.be.equal("a.sweno@hotmail.com")
        .then resolve
        .catch reject
        .finally recordingDone
