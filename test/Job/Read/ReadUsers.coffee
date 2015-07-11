stream = require "readable-stream"

module.exports =
  beforeEach: ->
    Freshdesk = require "../../../lib/Binding/Freshdesk"
    binding = new Freshdesk(
      credential: config.credentials.denis
    )
    ReadUsers = require "../../../lib/Job/Read/ReadUsers"
    @job = new ReadUsers(
      binding: binding
      stream: new stream.Writable()
    )
  "ReadUsers":
    "should exist": ->
      @job.data = {}
#      @job.run()
#      @job.on "data", (chunk) ->
#        should.exist(chunk)
#      @job.on "end", done
      # data listener should.be.called
