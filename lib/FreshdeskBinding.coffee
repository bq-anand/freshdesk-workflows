_ = require "underscore"
errors = require "../helper/errors"
Binding = require "../core/lib/Binding"
BasicAuthentication = require "../core/lib/Authentication/BasicAuthentication"

class FreshdeskBinding extends Binding
  constructor: (options) ->
    _.defaults options,
      api: "Freshdesk"
    super

  request: (options) ->
    _.defaults(options,
      baseUrl: "https://#{@credential.details.domain}"
      json: true
    )
    BasicAuthentication(@credential.details, options)
    super(options).spread (response, body) ->
      if response.statusCode is 403
        throw new errors.RateLimitReachedError
          response: response.toJSON()
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

module.exports = FreshdeskBinding
