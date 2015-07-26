_ = require "underscore"
_.mixin require "underscore.deep"
moment = require "moment"
Serializer = require "../core/lib/Serializer"

class FreshdeskSerializer extends Serializer
  constructor: (options) ->
    super

  keymap: ->
    "id": "_uid"

  # toDate not overridden
  # fromDate overridden for utcOffset(-4)
  fromDate: (value) -> moment(value).utcOffset(-4).format(@dateFormat())
  dateFormat: -> "YYYY-MM-DDTHH:mm:ssZ"

module.exports = FreshdeskSerializer
