_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createDependencies = require "../../core/test-helper/dependencies"
settings = (require "../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskSerializer = require "../../lib/FreshdeskSerializer"
createFreshdeskUsers = require "../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskSerializer", ->
  dependencies = createDependencies(settings)
  knex = dependencies.knex; bookshelf = dependencies.bookshelf

  FreshdeskUsers = createFreshdeskUsers bookshelf

  serializer = null

  after (teardownDone) ->
    knex.destroy()
    .nodeify teardownDone

  beforeEach ->
    serializer = new FreshdeskSerializer
      model: FreshdeskUsers

  it "should be idempotent", ->
    sampleMirror = serializer.toExternal(serializer.toInternal(sample))
    sample.should.be.deep.equal(sampleMirror)

  it "should remap id to _uid", ->
    serializer.toInternal(sample)._uid.should.be.equal(sample.id)

  it "should transform created_at::string into created_at::Date", ->
    serializer.toInternal(sample).created_at.should.be.an.instanceof(Date)
