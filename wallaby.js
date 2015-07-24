var _ = require("underscore");
_.mixin(require("underscore.deep"));

var config = function(local, wallaby) {
  process.env.NODE_PATH += ":" + require('path').join(wallaby.localProjectDir, 'core', 'node_modules');
  return _.deepExtend({
    testFramework: "mocha",
    files: [
      "!test/**/*Spec.coffee",
      "**/helper/**/*.coffee",
      "**/lib/**/*.coffee",
      "test/helpers.coffee",
      "test/mocha.coffee",
      "test/config.json"
    ],
    tests: [
      "test/**/*Spec.coffee"
    ],
    env: {
      type: "node",
      runner: "node"
    },
    bootstrap: function(wallaby) {
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
};

var local = getLocalWallaby();
local.env = local.env || {};
local.env.params = local.env.params || {};
local.env.params.env = local.env.params.env || "";
local.env.params.env += ";ROOT_DIR=" + process.cwd();

/* Duplicate code, because wallaby.js and bootstrap() run in different contexts */
function getLocalWallaby() {
  var local = {};
  try {
    local = require("./wallaby.local");
    delete local.bootstrap; // explicitly called inside global bootstrap (defined in this file)
  } catch (error) {
    if (error.code !== "MODULE_NOT_FOUND") { // unexpected!
      throw error;
    }
  }
  return local;
}

module.exports = _.partial(config, local);
