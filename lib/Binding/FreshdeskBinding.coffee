_ = require "underscore"
BasicAuthentication = require "../../core/Authentication/BasicAuthentication"

class FreshdeskBinding extends require "../../core/Binding"

  request: (options) ->
    _.defaults(options,
      baseUrl: "https://#{@credential.domain}"
      json: true
    )
    BasicAuthentication(@credential, options)
    super(options)

  getUsers: (qs, options) ->
    @request _.extend
      method: "GET"
      url: "/contacts.json"
      qs: qs
    , options

module.exports = FreshdeskBinding
