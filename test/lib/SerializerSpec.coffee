_ = require "underscore"
helpers = require "../helpers"
Serializer = require "../../lib/Serializer"
createUser = require "../../lib/Model/User"

describe "Serializer", ->
  serializer = null; external = null; knex = null; User = null;

  before (beforeDone) ->
    knex = helpers.createKnex()
    bookshelf = helpers.createBookshelf(knex)
    User = createUser(bookshelf)
    beforeDone()

  after (teardownDone) ->
    knex.destroy()
    .nodeify teardownDone

  beforeEach (setupDone) ->
    serializer = new Serializer(
      model: User
    )
    external = {
      "active": true,
      "created_at": "2015-07-11T06:33:38-04:00",
      "customer_id": null,
      "deleted": false,
      "description": null,
      "email": "example@example.com",
      "external_id": null,
      "fb_profile_id": null,
      "helpdesk_agent": false,
      "id": 6001911496,
      "job_title": null,
      "language": "en",
      "mobile": null,
      "name": "example327",
      "phone": null,
      "time_zone": "Eastern Time (US & Canada)",
      "twitter_id": null,
      "updated_at": "2015-07-11T06:33:38-04:00",
      "company_id": null,
      "custom_field": {}
    }
    setupDone()

  it "should be idempotent", (testDone) ->
    external2 = serializer.toExternal(serializer.toInternal(external))
    # Freshdesk outputs date in a slightly different format
    # Their version: '2015-07-11T06:33:38-04:00'
    # Our version: '2015-07-11T10:33:38.000Z'
    # Hope they will accept our format
    external.created_at = new Date(external.created_at).toISOString()
    external.updated_at = new Date(external.updated_at).toISOString()
    external.should.be.deep.equal(external2)
    testDone()

  it "should remap id to uid", (testDone) ->
    serializer.toInternal(external).uid.should.be.equal(6001911496)
    testDone()

  it "should transform created_at::string into createdAt::Date", (testDone) ->
    serializer.toInternal(external).createdAt.should.be.an.instanceof(Date)
    testDone()

  it "should transform helpdesk_agent::Boolean into isHelpdeskAgent::Boolean", (testDone) ->
    serializer.toInternal(external).isHelpdeskAgent.should.be.a("boolean")
    testDone()
