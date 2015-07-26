_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Download = require "../../../../core/lib/Task/ActivityTask/Download"
ReadUsers = require "../Read/ReadUsers"
SaveUsers = require "../Save/SaveUsers"

class DownloadUsers extends Download
  constructor: (input, options, dependencies) ->
    Match.check input,
      ReadUsers: Object
      SaveUsers: Object
    super input, options, _.extend {}, dependencies,
      read: new ReadUsers input.ReadUsers.input, input.ReadUsers, dependencies
      save: new SaveUsers input.SaveUsers.input, input.ReadUsers, dependencies

module.exports = DownloadUsers