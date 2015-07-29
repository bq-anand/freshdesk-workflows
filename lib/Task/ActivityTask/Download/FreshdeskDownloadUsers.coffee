_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Download = require "../../../../core/lib/Task/ActivityTask/Download"
FreshdeskReadUsers = require "../BindingTask/Read/FreshdeskReadUsers"
FreshdeskSaveUsers = require "../Save/FreshdeskSaveUsers"

class FreshdeskDownloadUsers extends Download
  constructor: (input, options, streams, dependencies) ->
    Match.check input, Match.ObjectIncluding
      FreshdeskReadUsers: Object
      FreshdeskSaveUsers: Object
    readArguments = @arguments input, "FreshdeskReadUsers"
    saveArguments = @arguments input, "FreshdeskSaveUsers"
    _.extend @,
      read: new FreshdeskReadUsers readArguments.input, readArguments.options, streams, dependencies
      save: new FreshdeskSaveUsers saveArguments.input, saveArguments.options, streams, dependencies
    super

module.exports = FreshdeskDownloadUsers
