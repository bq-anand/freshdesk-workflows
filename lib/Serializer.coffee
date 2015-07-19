_ = require "underscore"
_.mixin require "underscore.deep"
camelize = require "underscore.string/camelize"
underscore = require "underscore.string/underscored"
BaseSerializer = require ".././Serializer"

class Serializer extends BaseSerializer
  constructor: (options) ->
    super
    keymap = @keymap()
    _.extend @,
      key:
        toInternal: _.compose @dereference.bind(@, keymap), camelize
        toExternal: _.compose underscore, @dereference.bind(@, _.invert keymap)
      values: @forJSONResponse()

  # in camelized format
  keymap: ->
    keymap =
      "id": "uid"
    for column in @model.getColumns()
      if column.getColumnType() is "boolean"
        name = column.getColumnName()
        keymap[camelize(underscore(name).replace("is_", ""))] = name
    keymap

module.exports = Serializer
