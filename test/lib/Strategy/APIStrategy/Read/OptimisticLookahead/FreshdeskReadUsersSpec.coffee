_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
input = require "../../../../../../core/test-helper/input"
createDependencies = require "../../../../../../core/helper/dependencies"
settings = (require "../../../../../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/test.json")

FreshdeskReadUsers = require "../../../../../../lib/Strategy/APIStrategy/Read/OptimisticLookahead/FreshdeskReadUsers"

describe "FreshdeskReadUsers", ->
  dependencies = createDependencies(settings, "FreshdeskReadUsers")
  mongodb = dependencies.mongodb;

  Credentials = mongodb.collection("Credentials")
  Commands = mongodb.collection("Commands")
  Issues = mongodb.collection("Issues")

  strategy = null;

  before ->

  beforeEach ->
    strategy = new FreshdeskReadUsers(
      _.defaults
        params: {}
      , input
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
          avatarId: strategy.avatarId
          api: "Freshdesk"
          scopes: ["*"]
          details: settings.credentials["Freshdesk"]["Generic"]
      ]

  afterEach ->

  it "should run @fast", ->
    @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
    new Promise (resolve, reject) ->
      nock.back "test/fixtures/FreshdeskReadUsers/normal.json", (recordingDone) ->
        onBindingRequest = sinon.spy(strategy.binding, "request")
        onObjectSpy = sinon.spy()
        strategy.on "object", onObjectSpy
        strategy.execute()
        .then ->
          onBindingRequest.should.have.callCount(20)
          onObjectSpy.should.have.callCount(934)
          onObjectSpy.should.always.have.been.calledWithMatch sinon.match (object) ->
            object.hasOwnProperty("email")
          , "Object has own property \"email\""
        .then resolve
        .catch reject
        .finally recordingDone
