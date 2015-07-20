_ = require "underscore"
_.mixin require "underscore.deep"
BaseSerializer = require "../core/lib/Serializer"

class Serializer extends BaseSerializer
  constructor: (options) ->
    super

module.exports = Serializer
