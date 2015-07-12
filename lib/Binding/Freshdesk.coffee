_ = require "underscore"
Binding = require "../../core/Binding"
Exception = require "../../core/Exception"
BasicAuthentication = require "../../core/Authentication/BasicAuthentication"

class Freshdesk extends Binding

  request: (options) ->
    _.defaults(options,
      baseUrl: "https://#{@credential.domain}"
      json: true
    )
    BasicAuthentication(@credential, options)
    super(options).spread (response, body) ->
      if response.statusCode is 403
#        throw new Error "Binding.rateLimitReached"
#        console.log response
#        console.log body
        throw new Exception "Binding.rateLimitReached",
          response: response
          body: body
      [response, body]

  getUsers: (qs, options) ->
    @request _.extend
      method: "GET"
      url: "/contacts.json"
      qs: qs
    , options
    .spread (response, body) ->
      [response, _.pluck(body, "user")] # Freshdesk wraps each body object in another object with a single key

module.exports = Freshdesk
