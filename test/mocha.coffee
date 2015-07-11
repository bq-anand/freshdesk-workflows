chai = require "chai"
global.should = chai.should()
#chai.config.includeStack = true

chaiAsPromised = require "chai-as-promised"
chai.use(chaiAsPromised)

nconf = require "nconf"
global.config = nconf.file({file: "test/config.json"}).get()

