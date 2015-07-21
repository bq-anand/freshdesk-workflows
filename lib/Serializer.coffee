_ = require "underscore"
_.mixin require "underscore.deep"
BaseSerializer = require "../core/lib/Serializer"

class Serializer extends BaseSerializer
  constructor: (options) ->
    super

  keymap: ->
    "id": "_uid"

module.exports = Serializer
