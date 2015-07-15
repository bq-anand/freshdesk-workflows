var local = getLocalWallaby();
var _ = require("underscore");
underscoreDeepExtend = require("underscore-deep-extend");
_.mixin({deepExtend: underscoreDeepExtend(_)});

var config = _.deepExtend({
  testFramework: "mocha",
  files: [
    "core/**/*.coffee",
    "lib/**/*.coffee",
    "test/mocha.coffee",
    "test/config.json"
  ],
  tests: [
    "test/**/*Spec.coffee",
    "!test/config.json",
    "!test/mocha.coffee",
    "!test/mocha.opts"
  ],
  env: {
    type: "node",
    runner: "node"
  },
  bootstrap: function (wallaby) {
    var mocha = wallaby.testFramework;
    mocha.ui("bdd");
    require.main.require("test/mocha");
    try {
      var local = require(wallaby.localProjectDir + "/wallaby.local"); // need to require again here, because bootstrap runs in another context
      local.bootstrap && local.bootstrap(wallaby)
    } catch (error) {
      if (error.code !== "MODULE_NOT_FOUND") { // unexpected!
        throw error;
      }
    }
  }
}, local);

config.env = config.env || {};
config.env.params = config.env.params || {};
config.env.params.env = config.env.params.env || "";
config.env.params.env += ";ROOT_DIR="+process.cwd();

/* Duplicate code, because wallaby.js and bootstrap() run in different contexts */
function getLocalWallaby() {
  var local = {};
  try {
    local = require("./wallaby.local");
    delete local.bootstrap; // explicitly called inside global boostrap (defined in this file)
  } catch (error) {
    if (error.code !== "MODULE_NOT_FOUND") { // unexpected!
      throw error;
    }
  }
  return local;
}

module.exports = config;
