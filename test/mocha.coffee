rootDir = process.env.ROOT_DIR or process.cwd()

chai = require "chai"
global.should = chai.should()
#chai.config.includeStack = true

chaiAsPromised = require "chai-as-promised"
chai.use(chaiAsPromised)

chaiThings = require "chai-things"
chai.use(chaiThings)

chaiSinon = require "sinon-chai"
chai.use(chaiSinon)

global.sinon = require("sinon")

global.nconf = require "nconf"
global.config = global.nconf.file({file: "#{rootDir}/test/config.json"}).get()

global.Promise = require "bluebird"

global.nock = require "nock"
global.nock.back.fixtures = "#{rootDir}/test/Binding/fixtures"
global.nock.back.setMode(process.env.NOCK_BACK_MODE or "lockdown")
# override default to be "lockdown" instead of "dryrun", otherwise we run into rate limits pretty soon
# run "NOCK_BACK_MODE=record mocha path/to/your/test.coffee" manually to record API responses
