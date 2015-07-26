_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
createLogger = require "../../core/helper/logger"
createKnex = require "../../core/helper/knex"
createBookshelf = require "../../core/helper/bookshelf"
settings = (require "../../core/helper/settings")("#{process.env.ROOT_DIR}/settings/dev.json")

FreshdeskSerializer = require "../../lib/FreshdeskSerializer"
createFreshdeskUser = require "../../lib/Model/FreshdeskUser"
sample = require "#{process.env.ROOT_DIR}/test/fixtures/FreshdeskSaveUsers/sample.json"

describe "FreshdeskSerializer", ->
  serializer = null; knex = null; FreshdeskUser = null;

  before (beforeDone) ->
    knex = createKnex settings.knex
    bookshelf = createBookshelf knex
    FreshdeskUser = createFreshdeskUser bookshelf
    beforeDone()

  after (teardownDone) ->
    knex.destroy()
    .nodeify teardownDone

  beforeEach ->
    serializer = new FreshdeskSerializer
      model: FreshdeskUser

  it "should be idempotent", ->
    sampleMirror = serializer.toExternal(serializer.toInternal(sample))
    sample.should.be.deep.equal(sampleMirror)

  it "should remap id to _uid", ->
    serializer.toInternal(sample)._uid.should.be.equal(sample.id)

  it "should transform created_at::string into created_at::Date", ->
    serializer.toInternal(sample).created_at.should.be.an.instanceof(Date)
