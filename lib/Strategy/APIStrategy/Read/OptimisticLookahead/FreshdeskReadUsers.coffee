_ = require "underscore"
Promise = require "bluebird"
OptimisticLookahead = require "../../../../../core/lib/Strategy/APIStrategy/Read/OptimisticLookahead"
FreshdeskBinding = require "../../../../FreshdeskBinding"

class FreshdeskReadUsers extends OptimisticLookahead
  createBinding: -> new FreshdeskBinding({scopes: ["*"]})
  shouldReadNextChapter: (response, body) -> _.isArray(body) and body.length
  getPage: (page) ->
    selector = {page: page}
    if @params.email
      selector.query = "email is #{@params.email}"
    @binding.getUsers(selector)

module.exports = FreshdeskReadUsers
