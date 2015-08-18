_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
input = require "../../../../../core/test-helper/input"
createDependencies = require "../../../../../core/helper/dependencies"
settings = (require "../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/test.json")

FreshdeskSaveUsers = require "../../../../../lib/Task/ActivityTask/Save/FreshdeskSaveUsers"
createFreshdeskUsers = require "../../../../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskSaveUsers", ->
  dependencies = createDependencies(settings, "FreshdeskSaveUsers")
  knex = dependencies.knex; bookshelf = dependencies.bookshelf; mongodb = dependencies.mongodb;

  FreshdeskUsers = createFreshdeskUsers bookshelf

  Commands = mongodb.collection("Commands")
  Issues = mongodb.collection("Issues")

  task = null; # shared between tests

  before ->
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> FreshdeskUsers.createTable()

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
        knex.truncate(FreshdeskUsers::tableName)
        Commands.remove()
        Issues.remove()
      ]
    .then ->
      Promise.all [
        Commands.insert
          _id: input.commandId
          progressBars: [
            activityId: "FreshdeskSaveUsers", isStarted: true, isCompleted: false, isFailed: false
          ]
          isStarted: true, isCompleted: false, isFailed: false
      ]

  it "should save new objects", ->
    task.in.write(sample)
    task.in.end()
    task.execute()
    .then ->
      knex(FreshdeskUsers::tableName).count("id")
      .then (results) ->
        results[0].count.should.be.equal("1")
    .then ->
      FreshdeskUsers.where({email: "example@example.com"}).fetch()
      .then (model) ->
        should.exist(model)
    .then ->
      Commands.findOne(input.commandId)
      .then (command) ->
        command.progressBars[0].total.should.be.equal(0)
        command.progressBars[0].current.should.be.equal(1)

  it "should update existing objects", ->
    task.in.write(sample)
    task.in.end()
    task.execute()
    .then ->
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
      task.in.write _.defaults
        "email": "another-example@example.com",
      , sample
      task.in.end()
      task.execute()
    .then ->
      knex(FreshdeskUsers::tableName).count("id")
      .then (results) ->
        results[0].count.should.be.equal("1")
    .then ->
      FreshdeskUsers.where({email: "another-example@example.com"}).fetch()
      .then (model) ->
        should.exist(model)
