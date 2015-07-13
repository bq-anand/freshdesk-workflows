Promise = require "bluebird"
execAsync = Promise.promisify (require "child_process").exec
SaveUsers = require "../../../lib/Job/Save/SaveUsers"
createKnex = require "knex"
createBookshelf = require "bookshelf"
createAvatar = require "../../../core/Model/Avatar"
createFreshdeskUser = require "../../../lib/Model/FreshdeskUser"

exec = (require "child_process").exec


describe "SaveUsers", ->
  knex = bookshelf = FreshdeskUser = job = null

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
      email: "hey@example.com"
      active: true
      avatarId: 1
      isDeleted: true
    ])
#    .then ->
#      job.knex.
    .nodeify testDone
