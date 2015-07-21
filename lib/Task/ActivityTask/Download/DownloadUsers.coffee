_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Download = require "../../../../core/lib/Task/ActivityTask/Download"
ReadUsers = require "../Read/ReadUsers"
SaveUsers = require "../Save/SaveUsers"

class DownloadUsers extends Download
  constructor: (options, dependencies) ->
    Match.check options,
      ReadUsers: Object
      SaveUsers: Object
    super options, _.extend {}, dependencies,
      read: new ReadUsers options.ReadUsers, dependencies
      save: new SaveUsers options.SaveUsers, dependencies

module.exports = DownloadUsers