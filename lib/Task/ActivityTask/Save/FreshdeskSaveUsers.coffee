UpsertThroughTemporaryTable = require "../../../../core/lib/Task/ActivityTask/Save/UpsertThroughTemporaryTable"
createFreshdeskUsers = require "../../../Model/FreshdeskUsers"
FreshdeskSerializer = require "../../../FreshdeskSerializer"

class FreshdeskSaveUsers extends UpsertThroughTemporaryTable
  createModel: -> createFreshdeskUsers(@bookshelf)
  createSerializer: -> new FreshdeskSerializer({model: @model})

module.exports = FreshdeskSaveUsers
