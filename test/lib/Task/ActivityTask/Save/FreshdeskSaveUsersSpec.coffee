_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../../../../core/helper/logger"
createKnex = require "../../../../../core/helper/knex"
createBookshelf = require "../../../../../core/helper/bookshelf"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskSaveUsers = require "../../../../../lib/Task/ActivityTask/Save/FreshdeskSaveUsers"
createFreshdeskUsers = require "../../../../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskSaveUsers", ->
  knex = null; bookshelf = null; logger = null; FreshdeskUser = null; task = null; # shared between tests

  before (beforeDone) ->
    knex = createKnex settings.knex
    knex.Promise.longStackTraces()
    bookshelf = createBookshelf knex
    logger = createLogger settings.logger
    FreshdeskUser = createFreshdeskUsers bookshelf
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> FreshdeskUser.createTable()
    .nodeify beforeDone

  after (teardownDone) ->
    knex.destroy()
    .nodeify teardownDone

  beforeEach ->
    task = new FreshdeskSaveUsers(
      avatarId: "wuXMSggRPPmW4FiE9"
    ,
      {}
    ,
      logger: logger
      bookshelf: bookshelf
      in: new stream.PassThrough({objectMode: true})
      out: new stream.PassThrough({objectMode: true})
    )

  it "should run", ->
    task.in.write(sample)
    task.in.end()
    task.execute()
    .then ->
      knex(FreshdeskUser::tableName).count("id")
      .then (results) ->
        results[0].count.should.be.equal("1")
    .then ->
      FreshdeskUser.where({id: 1}).fetch()
      .then (model) ->
        model.get("email").should.be.equal("example@example.com")
