_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
MemoryLeakTester = require "../../core/lib/MemoryLeakTester"
createDependencies = require "../../core/helper/dependencies"
settings = (require "../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/test.json")

FreshdeskSerializer = require "../../lib/FreshdeskSerializer"
createFreshdeskUsers = require "../../lib/Model/FreshdeskUsers"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskSerializer", ->
  dependencies = createDependencies(settings, "FreshdeskSerializer")
  knex = dependencies.knex; bookshelf = dependencies.bookshelf

  FreshdeskUsers = createFreshdeskUsers bookshelf

  serializer = null

  after ->
    knex.destroy()

  beforeEach ->
    serializer = new FreshdeskSerializer
      model: FreshdeskUsers

  it "should be idempotent @fast", ->
    sampleMirror = serializer.toExternal(serializer.toInternal(sample))
    sample.should.be.deep.equal(sampleMirror)

  it "should remap id to _uid @fast", ->
    serializer.toInternal(sample)._uid.should.be.equal(sample.id)

  it "should transform created_at::string into created_at::Date @fast", ->
    serializer.toInternal(sample).created_at.should.be.an.instanceof(Date)

  it "shouldn't leak memory @slow", ->
    @timeout(60000)
    tester = new MemoryLeakTester(
      runner: ->
        serializer.toExternal(serializer.toInternal(sample))
    )
    tester.execute()
