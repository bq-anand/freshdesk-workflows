_ = require "underscore"
Promise = require "bluebird"
Download = require "../../../core/lib/Task/ActivityTask/Download"
ReadUsers = require "../Read/ReadUsers"
SaveUsers = require "../Save/SaveUsers"

class DownloadUsers extends Download
  constructor: (options) ->
    options.read = new ReadUsers _.clone options
    options.save = new SaveUsers _.clone options
    super

module.exports = DownloadUsers