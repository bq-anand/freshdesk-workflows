_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
input = require "../../../../../../core/test-helper/input"
createDependencies = require "../../../../../../core/helper/dependencies"
settings = (require "../../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/test.json")

FreshdeskSaveUsers = require "../../../../../../lib/Strategy/DBStrategy/Save/TemporaryTable/FreshdeskSaveUsers"
createFreshdeskUsers = require "../../../../../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskSaveUsers", ->
  dependencies = createDependencies(settings, "FreshdeskSaveUsers")
  knex = dependencies.knex; bookshelf = dependencies.bookshelf; mongodb = dependencies.mongodb;

  FreshdeskUsers = createFreshdeskUsers bookshelf

  Commands = mongodb.collection("Commands")
  Issues = mongodb.collection("Issues")

  strategy = null; # shared between tests

  before ->
    Promise.bind(@)
    .then -> knex.raw("SET search_path TO pg_temp")
    .then -> FreshdeskUsers.createTable()

  after ->
    knex.destroy()

  beforeEach ->
    strategy = new FreshdeskSaveUsers(
      _.defaults {}, input
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

  it "should save new objects @fast", ->
    knex.transaction (transaction) =>
      Promise.bind(@)
      .then -> strategy.start(transaction)
      .then -> strategy.insert(sample)
      .then -> strategy.finish()
    .then ->
      knex(FreshdeskUsers::tableName).count("id")
      .then (results) ->
        results[0].count.should.be.equal("1")
    .then ->
      FreshdeskUsers.where({email: "example@example.com"}).fetch()
      .then (model) ->
        should.exist(model)

  it "should update existing objects @fast", ->
    Promise.bind(@)
    .then ->
      knex.transaction (transaction) =>
        strategy = new FreshdeskSaveUsers(
          _.defaults {}, input
        ,
          dependencies
        )
        Promise.bind(@)
        .then -> strategy.start(transaction)
        .then -> strategy.insert(sample)
        .then -> strategy.finish()
    .then ->
      knex.transaction (transaction) =>
        strategy = new FreshdeskSaveUsers(
          _.defaults {}, input
        ,
          dependencies
        )
        Promise.bind(@)
        .then -> strategy.start(transaction)
        .then -> strategy.insert _.defaults
          "email": "another-example@example.com",
        , sample
        .then -> strategy.finish()
    .then ->
      knex(FreshdeskUsers::tableName).count("id")
      .then (results) ->
        results[0].count.should.be.equal("1")
    .then ->
      FreshdeskUsers.where({email: "another-example@example.com"}).fetch()
      .then (model) ->
        should.exist(model)
