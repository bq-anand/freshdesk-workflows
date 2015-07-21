_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../../../../core/helper/logger"
createKnex = require "../../../../../core/helper/knex"
createBookshelf = require "../../../../../core/helper/bookshelf"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

SaveUsers = require "../../../../../lib/Task/ActivityTask/Save/SaveUsers"
createUser = require "../../../../../lib/Model/User"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/SaveUsers/sample.json"

describe "SaveUsers", ->
  knex = null; bookshelf = null; logger = null; User = null; task = null; # shared between tests

  before (beforeDone) ->
    knex = createKnex settings.knex
    knex.Promise.longStackTraces()
    bookshelf = createBookshelf knex
    logger = createLogger settings.logger
    User = createUser bookshelf
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> User.createTable()
    .nodeify beforeDone

  after (teardownDone) ->
    knex.destroy()
    .nodeify teardownDone

  beforeEach ->
    task = new SaveUsers(
      avatarId: "wuXMSggRPPmW4FiE9"
    ,
      in: new stream.PassThrough({objectMode: true})
      out: new stream.PassThrough({objectMode: true})
      bookshelf: bookshelf
      logger: logger
    )

  it "should run", ->
    task.in.write(sample)
    task.in.end()
    task.execute()
    .then ->
      knex(User::tableName).count("id")
      .then (results) ->
        results[0].count.should.be.equal("1")
    .then ->
      User.where({id: 1}).fetch()
      .then (model) ->
        model.get("email").should.be.equal("example@example.com")
