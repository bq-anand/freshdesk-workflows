_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Download = require "../../../../core/lib/Task/ActivityTask/Download"
FreshdeskReadUsers = require "../BindingTask/Read/FreshdeskReadUsers"
FreshdeskSaveUsers = require "../Save/FreshdeskSaveUsers"

class FreshdeskDownloadUsers extends Download
  constructor: (input, options, streams, dependencies) ->
    Match.check input,
      FreshdeskReadUsers: Object
      FreshdeskSaveUsers: Object
    _.extend @,
      read: new FreshdeskReadUsers input.FreshdeskReadUsers.input, input.FreshdeskReadUsers, streams, dependencies
      save: new FreshdeskSaveUsers input.FreshdeskSaveUsers.input, input.FreshdeskReadUsers, streams, dependencies
    super


module.exports = FreshdeskDownloadUsers