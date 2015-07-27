_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createDependencies = require "../../../../../core/helper/dependencies"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskBinding = require "../../../../../lib/FreshdeskBinding"
FreshdeskDownloadUsers = require "../../../../../lib/Task/ActivityTask/Download/FreshdeskDownloadUsers"
createFreshdeskUsers = require "../../../../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskDownloadUsers", ->
  dependencies = createDependencies(settings)
  knex = dependencies.knex; bookshelf = dependencies.bookshelf; mongodb = dependencies.mongodb

  Credentials = mongodb.collection("Credentials")

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
