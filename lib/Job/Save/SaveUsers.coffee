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
      new Promise (resolve, reject) =>
        inserts = []
        @input.on "readable", =>
          while (object = @input.read()) isnt null # result may also be false, so we can't write `while (result = @input.read())`
            inserts.push @insert(object) if object
          true
        @input.on "end", -> resolve(inserts)
        @input.on "error", reject
    .all() # wait for objects to be inserted
    .then @save

module.exports = SaveUsers
