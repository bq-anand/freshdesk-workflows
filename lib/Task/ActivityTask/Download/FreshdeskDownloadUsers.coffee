_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Download = require "../../../../core/lib/Task/ActivityTask/Download"
FreshdeskReadUsers = require "../Read/FreshdeskReadUsers"
FreshdeskSaveUsers = require "../Save/FreshdeskSaveUsers"

class FreshdeskDownloadUsers extends Download
  constructor: (input, options, dependencies) ->
    Match.check input,
      FreshdeskReadUsers: Object
      FreshdeskSaveUsers: Object
    super input, options, _.extend {}, dependencies,
      read: new FreshdeskReadUsers input.FreshdeskReadUsers.input, input.FreshdeskReadUsers, dependencies
      save: new FreshdeskSaveUsers input.FreshdeskSaveUsers.input, input.FreshdeskReadUsers, dependencies

module.exports = FreshdeskDownloadUsers