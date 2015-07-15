UpsertThroughTemporaryTable = require "../../../core/Job/Save/UpsertThroughTemporaryTable"
createUser = require "../../Model/User"
Serializer = require "../../Serializer"

class SaveUsers extends UpsertThroughTemporaryTable
  createModel: -> createUser(@bookshelf)
  createSerializer: -> new Serializer({model: @model})

module.exports = SaveUsers
