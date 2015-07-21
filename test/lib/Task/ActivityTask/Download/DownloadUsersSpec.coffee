Promise = require "bluebird"
stream = require "readable-stream"
helpers = require "../../../../../core/test/helpers"
Binding = require "../../../../../lib/Binding"
DownloadUsers = require "../../../../../lib/Task/ActivityTask/Download/DownloadUsers"
createUser = require "../../../../../lib/Model/User"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

describe "DownloadUsers", ->
  job = null; binding = null; knex = null; bookshelf = null; User = null; job = null; # shared between tests

  before (beforeDone) ->
    knex = helpers.createKnex()
    bookshelf = helpers.createBookshelf(knex)
    User = createUser(bookshelf)
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> User.createTable()
    .nodeify beforeDone

  after (teardownDone) ->
    knex.destroy()
    .nodeify teardownDone

  beforeEach (setupDone) ->
    binding = new Binding(
      credential: settings.credentials.denis
    )
    job = new DownloadUsers(
      ReadUsers:
        avatarId: "wuXMSggRPPmW4FiE9"
      SaveUsers:
        avatarId: "wuXMSggRPPmW4FiE9"
    ,
      binding: binding
      bookshelf: bookshelf
      input: new stream.PassThrough({objectMode: true})
      output: new stream.PassThrough({objectMode: true})
    )
    setupDone()

  it "should run", (testDone) ->
    nock.back "test/fixtures/ReadUsersNormalOperation.json", (recordingDone) =>
      done = (error) -> recordingDone(); testDone(error)
      job.execute()
      .then ->
        knex(User::tableName).count("id")
        .then (results) ->
          results[0].count.should.be.equal("934")
      .then ->
        User.where({email: "a.sweno@hotmail.com"}).fetch()
        .then (model) ->
          should.exist(model)
          model.get("email").should.be.equal("a.sweno@hotmail.com")
      .nodeify done
      job.input.write(
        id: 1
        email: "example@example.com"
        active: true
        deleted: true
        created_at: new Date()
        updated_at: new Date()
      )
      job.input.end()
#      job.run()
#      job.on "data", onData
#      job.on "end", ->
#        try
#          request.should.have.callCount(20)
#          onData.should.have.callCount(934)
#          onData.should.always.have.been.calledWithMatch sinon.match (object) ->
#            object.hasOwnProperty("email")
#          , "Object has own property \"email\""
#          done()
#        catch error
#          done(error)
#      job.on "error", done
