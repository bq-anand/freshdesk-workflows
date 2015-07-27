_ = require "underscore"
Promise = require "bluebird"
OptimisticLookahead = require "../../../../../core/lib/Task/ActivityTask/BindingTask/Read/OptimisticLookahead"
FreshdeskBinding = require "../../../../FreshdeskBinding"

class FreshdeskReadUsers extends OptimisticLookahead
  createBinding: -> new FreshdeskBinding({scopes: ["*"]})
  shouldReadNextChapter: (response, body) -> _.isArray(body) and body.length
  getPage: (page) -> @binding.getUsers({page: page})

module.exports = FreshdeskReadUsers
