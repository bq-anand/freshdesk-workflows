#Freshdesk = require "../../../lib/Binding/Freshdesk"
#DownloadUsers = require "../../../lib/Job/Download/DownloadUsers"
#
#describe "DownloadUsers", ->
#  job = null; binding = null;
#
#  beforeEach (setupDone) ->
#    binding = new Freshdesk(
#      credential: config.credentials.denis
#    )
#    job = new ReadUsers(
#      binding: binding
#    )
#    setupDone()
#
#  it "should run", (testDone) ->
#    nock.back "Job/Read/ReadUsersFixtures/ReadUsers.json", (recordingDone) =>
#      @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
#      done = (error) -> recordingDone(); testDone(error)
#      onData = sinon.stub()
#      request = sinon.spy(job.binding, "request")
#      job.run()
#      job.on "data", onData
#      job.on "end", ->
#        try
#          request.should.have.callCount(20)
#          onData.should.have.callCount(934)
#          onData.should.always.have.been.calledWithMatch sinon.match (object) ->
#            object.hasOwnProperty("email")
#          , "Object has own property \"email\""
#          done()
#        catch error
#          done(error)
#      job.on "error", done
