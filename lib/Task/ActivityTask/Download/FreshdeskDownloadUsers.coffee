_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Download = require "../../../../core/lib/Task/ActivityTask/Download"
FreshdeskReadUsers = require "../../../Strategy/APIStrategy/Read/OptimisticLookahead/FreshdeskReadUsers"
FreshdeskSaveUsers = require "../../../Strategy/DBStrategy/Save/TemporaryTable/FreshdeskSaveUsers"

class FreshdeskDownloadUsers extends Download
  constructor: (input, options, dependencies) ->
    Match.check input, Match.ObjectIncluding
      FreshdeskReadUsers: Object
      FreshdeskSaveUsers: Object
    super

  createReadStrategy: -> new FreshdeskReadUsers @FreshdeskReadUsers, @dependencies
  createSaveStrategy: -> new FreshdeskSaveUsers @FreshdeskSaveUsers, @dependencies

module.exports = FreshdeskDownloadUsers
