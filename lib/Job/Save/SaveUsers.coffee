_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Save = require "../../../core/Job/Save"
createFreshdeskUser = require "../../Model/FreshdeskUser"

class SaveUsers extends Save
  constructor: (options) ->
    Match.check(options.bookshelf, Object)
    _.defaults options,
      model: createFreshdeskUser(options.bookshelf)
    super(options)
  run: (objects) ->
    Promise.bind(@)
    .then @init
    .then ->
      @push(object) for object in objects
    .all() # wait for objects to be inserted
    .then @save

module.exports = SaveUsers
