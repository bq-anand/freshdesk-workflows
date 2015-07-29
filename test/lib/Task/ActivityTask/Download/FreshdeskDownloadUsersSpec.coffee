_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
input = require "../../../../../core/test-helper/input"
createDependencies = require "../../../../../core/helper/dependencies"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskBinding = require "../../../../../lib/FreshdeskBinding"
FreshdeskDownloadUsers = require "../../../../../lib/Task/ActivityTask/Download/FreshdeskDownloadUsers"
createFreshdeskUsers = require "../../../../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskDownloadUsers", ->
  dependencies = createDependencies(settings, "FreshdeskDownloadUsers")
  knex = dependencies.knex; bookshelf = dependencies.bookshelf; mongodb = dependencies.mongodb

  Credentials = mongodb.collection("Credentials")
  Commands = mongodb.collection("Commands")
  Issues = mongodb.collection("Issues")

  FreshdeskUser = createFreshdeskUsers bookshelf

  task = null; # shared between tests

  before ->
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> FreshdeskUser.createTable()

  after ->
    knex.destroy()

  beforeEach ->
    task = new FreshdeskDownloadUsers(
      _.defaults
        FreshdeskReadUsers:
          input:
            avatarId: input.avatarId
            params: {}
        FreshdeskSaveUsers:
          input:
            avatarId: input.avatarId
            params: {}
      , input
    ,
      {}
    ,
      in: new stream.PassThrough({objectMode: true})
      out: new stream.PassThrough({objectMode: true})
    ,
      dependencies
    )
    Promise.bind(@)
    .then ->
      Promise.all [
        Credentials.remove()
        Commands.remove()
        Issues.remove()
      ]
    .then ->
      Promise.all [
        Credentials.insert
          avatarId: task.avatarId
          api: "Freshdesk"
          scopes: ["*"]
          details: settings.credentials["Freshdesk"]["Generic"]
        Commands.insert
          _id: task.commandId
          progressBars: [
            activityId: "FreshdeskReadUsers", isStarted: true, isFinished: false
          ,
            activityId: "FreshdeskSaveUsers", isStarted: true, isFinished: false
          ]
      ]

  afterEach ->

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
        .then ->
          Commands.findOne(task.commandId)
          .then (command) ->
            command.progressBars[0].total.should.be.equal(0)
            command.progressBars[0].current.should.be.equal(934)
            command.progressBars[1].total.should.be.equal(0)
            command.progressBars[1].current.should.be.equal(934)
        .then resolve
        .catch reject
        .finally recordingDone
