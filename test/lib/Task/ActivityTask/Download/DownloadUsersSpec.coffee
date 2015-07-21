_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../../../../core/helper/logger"
createKnex = require "../../../../../core/helper/knex"
createBookshelf = require "../../../../../core/helper/bookshelf"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

Binding = require "../../../../../lib/Binding"
DownloadUsers = require "../../../../../lib/Task/ActivityTask/Download/DownloadUsers"
createUser = require "../../../../../lib/Model/User"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/SaveUsers/sample.json"

describe "DownloadUsers", ->
  binding = null; knex = null; bookshelf = null; logger = null; User = null; task = null; # shared between tests

  before (beforeDone) ->
    knex = createKnex settings.knex
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
    binding = new Binding(
      credential: settings.credentials.denis
    )
    task = new DownloadUsers(
      ReadUsers:
        avatarId: "wuXMSggRPPmW4FiE9"
      SaveUsers:
        avatarId: "wuXMSggRPPmW4FiE9"
    ,
      input: new stream.PassThrough({objectMode: true})
      output: new stream.PassThrough({objectMode: true})
      binding: binding
      bookshelf: bookshelf
      logger: logger
    )

  it "should run", ->
    new Promise (resolve, reject) ->
      nock.back "test/fixtures/ReadUsersNormalOperation.json", (recordingDone) ->
        task.execute()
        .then ->
          knex(User::tableName).count("id")
          .then (results) ->
            results[0].count.should.be.equal("934")
        .then ->
          User.where({email: "a.sweno@hotmail.com"}).fetch()
          .then (model) ->
            should.exist(model)
            model.get("email").should.be.equal("a.sweno@hotmail.com")
        .then resolve
        .catch reject
        .finally recordingDone
