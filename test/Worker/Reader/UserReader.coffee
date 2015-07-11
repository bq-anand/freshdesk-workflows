module.exports =
  beforeEach: ->
    reader = require "../../../lib/Worker/Reader/UserReader"
    @reader = new reader(
      credential: config.credentials.denis
    )
  "UserReader":
    "should exist": ->
      should.exist(@reader)
