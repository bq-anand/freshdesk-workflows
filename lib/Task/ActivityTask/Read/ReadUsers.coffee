_ = require "underscore"
Promise = require "bluebird"
OptimisticLookahead = require "../../../../core/lib/Task/ActivityTask/Read/OptimisticLookahead"

class ReadUsers extends OptimisticLookahead
  shouldReadNextChapter: (response, body) -> _.isArray(body) and body.length
  getPage: (page) -> @binding.getUsers({page: page})

module.exports = ReadUsers
