SaveUsers = require "../../../lib/Job/Save/SaveUsers"

describe "SaveUsers", ->
  job = null

  beforeEach (setupDone) ->
    job = new SaveUsers(
      knex: knex
    )
    setupDone()

  it "should run", (testDone) ->
    knexTracker.on "query", (query) ->
      query.method.should.be.equal("insert")
    job.stream.push(
      email: "hey"
    )
    job.stream.push(null)
    testDone()
