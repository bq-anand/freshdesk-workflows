_ = require "underscore"
_.mixin require "underscore.deep"
moment = require "moment"
BaseSerializer = require "../core/lib/Serializer"

class Serializer extends BaseSerializer
  constructor: (options) ->
    super

  keymap: ->
    "id": "_uid"

  # toDate not overridden
  # fromDate overridden for utcOffset(-4)
  fromDate: (value) -> moment(value).utcOffset(-4).format(@dateFormat())
  dateFormat: -> "YYYY-MM-DDTHH:mm:ssZ"

module.exports = Serializer
