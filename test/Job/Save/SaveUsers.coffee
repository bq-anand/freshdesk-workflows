Promise = require "bluebird"
execAsync = Promise.promisify (require "child_process").exec
SaveUsers = require "../../../lib/Job/Save/SaveUsers"
createKnex = require "knex"
createBookshelf = require "bookshelf"
createAvatar = require "../../../core/Model/Avatar"
createFreshdeskUser = require "../../../lib/Model/FreshdeskUser"

exec = (require "child_process").exec


describe "SaveUsers", ->
  knex = null; bookshelf = null; FreshdeskUser = null; job = null; # shared between tests

  before (beforeDone) ->
    knex = createKnex(
      client: "pg"
      connection: "postgres://foreach:foreach@localhost/foreach_local"
      pool: {min: 1, max: 1}
    )
    knex.Promise.longStackTraces()
    bookshelf = createBookshelf(knex)
    Avatar = createAvatar(bookshelf)
    FreshdeskUser = createFreshdeskUser(bookshelf)
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> Avatar.createTable()
    .then -> FreshdeskUser.createTable()
    .then -> Avatar.forge({api: "Freshdesk", uid: 1, name: "Test Freshdesk account", userId: "u8vTsnsk2M7x8my9h"}).save()
    .nodeify(beforeDone)

  beforeEach (setupDone) ->
#    execAsync "pg_tmp 2>/dev/null"
#    .spread (postgresUrl) ->
      job = new SaveUsers(
        bookshelf: bookshelf
        avatarId: 1
      )
      setupDone()
#    .nodeify(setupDone)

  it "should run", (testDone) ->
    job.run([
      uid: "1"
      email: "example@example.com"
      active: true
      avatarId: 1
      isDeleted: true
    ])
    .then ->
      knex(FreshdeskUser::tableName).count("id")
      .then (results) ->
        results[0].count.should.be.equal("1")
    .then ->
      FreshdeskUser.where({id: 1}).fetch()
      .then (model) ->
        model.get("email").should.be.equal("example@example.com")
    .nodeify testDone
