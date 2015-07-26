UpsertThroughTemporaryTable = require "../../../../core/lib/Task/ActivityTask/Save/UpsertThroughTemporaryTable"
createFreshdeskUser = require "../../../Model/FreshdeskUser"
FreshdeskSerializer = require "../../../FreshdeskSerializer"

class FreshdeskSaveUsers extends UpsertThroughTemporaryTable
  createModel: -> createFreshdeskUser(@bookshelf)
  createSerializer: -> new FreshdeskSerializer({model: @model})

module.exports = FreshdeskSaveUsers
