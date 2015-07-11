module.exports = {
  debug: true,
  testFramework: "mocha",
  files: [
    "core/**/*.coffee",
    "lib/**/*.coffee",
    "test/mocha.coffee",
    "test/config.json"
  ],
  tests: [
    "test/**/*",
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
    mocha.ui("exports");
    require.main.require("test/mocha");
  }
};
