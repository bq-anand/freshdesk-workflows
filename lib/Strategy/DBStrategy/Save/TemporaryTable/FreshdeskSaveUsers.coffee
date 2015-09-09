TemporaryTable = require "../../../../../core/lib/Strategy/DBStrategy/Save/TemporaryTable"
createFreshdeskUsers = require "../../../../Model/FreshdeskUsers"
FreshdeskSerializer = require "../../../../FreshdeskSerializer"

class FreshdeskSaveUsers extends TemporaryTable
  createModel: -> createFreshdeskUsers(@bookshelf)
  createSerializer: -> new FreshdeskSerializer({model: @model})

module.exports = FreshdeskSaveUsers
