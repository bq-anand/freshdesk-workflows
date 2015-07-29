_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
input = require "../../../../../core/test-helper/input"
createDependencies = require "../../../../../core/helper/dependencies"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskSaveUsers = require "../../../../../lib/Task/ActivityTask/Save/FreshdeskSaveUsers"
createFreshdeskUsers = require "../../../../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskSaveUsers", ->
  dependencies = createDependencies(settings, "FreshdeskSaveUsers")
  knex = dependencies.knex; bookshelf = dependencies.bookshelf; mongodb = dependencies.mongodb;

  FreshdeskUser = createFreshdeskUsers bookshelf

  Commands = mongodb.collection("Commands")
  Issues = mongodb.collection("Issues")

  task = null; # shared between tests

  before ->
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> FreshdeskUser.createTable()

  after ->
    knex.destroy()

  beforeEach ->
    task = new FreshdeskSaveUsers(
      _.defaults {}, input
    ,
      activityId: "FreshdeskSaveUsers"
    ,
      in: new stream.PassThrough({objectMode: true})
      out: new stream.PassThrough({objectMode: true})
    ,
      dependencies
    )
    Promise.bind(@)
    .then ->
      Promise.all [
        Commands.remove()
        Issues.remove()
      ]
    .then ->
      Promise.all [
        Commands.insert
          _id: input.commandId
          progressBars: [
            activityId: "FreshdeskSaveUsers", isStarted: true, isFinished: false
          ]
      ]

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
    .then ->
      Commands.findOne(input.commandId)
      .then (command) ->
        command.progressBars[0].total.should.be.equal(0)
        command.progressBars[0].current.should.be.equal(1)
