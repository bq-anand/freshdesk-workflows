_ = require "underscore"
Job = require "../Job"
Match = require "mtr-match"

class Save extends Job
  constructor: (options) ->
    _.defaults options,
      bufferTableName: "UpsertData"
    Match.check(options,
      bookshelf: Object
      model: Function
      bufferTableName: String
      avatarId: Number
    )
    super
    @knex = @bookshelf.knex

  init: ->
    Promise.bind(@)
    .then ->
      @knex.raw("""
        DROP TABLE IF EXISTS "#{@bufferTableName}"
      """) # in case previous job errored out
    .then ->
      @knex.raw("""
        CREATE TEMPORARY TABLE IF NOT EXISTS "#{@bufferTableName}" (LIKE "#{@model::tableName}" INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING STORAGE)
      """)

  push: (object) ->
    @knex.insert(object).into(@bufferTableName)

  save: ->
    Promise.bind(@)
    .then ->
      @knex.transaction (trx) =>
        Promise.bind(@)
        .then ->
          trx.raw("""
              LOCK TABLE "#{@model::tableName}" IN EXCLUSIVE MODE
            """)
        .then ->
          trx.raw("""
              UPDATE "#{@model::tableName}" AS storage
              SET #{@getUpdateColumns("buffer")}
              FROM "#{@bufferTableName}" AS buffer
              WHERE storage."uid" = buffer."uid" AND storage."avatarId" = buffer."avatarId"
            """)
        .then ->
          trx.raw("""
              INSERT INTO "#{@model::tableName}"
              SELECT buffer.*
              FROM "#{@bufferTableName}" AS buffer
              LEFT OUTER JOIN "#{@model::tableName}" as storage ON (buffer."uid" = storage."uid" AND buffer."avatarId" = storage."avatarId")
              WHERE storage."id" IS NULL
            """)
      .then ->
        @knex.raw("""
          DROP TABLE IF EXISTS "#{@bufferTableName}"
        """)

  getUpdateColumns: (tableShortcut) ->
    columns = []
    for columnName in @model.getColumnNames()
      columns.push("\"#{columnName}\" = #{tableShortcut}.\"#{columnName}\"")
    columns.join()

  getSelectColumns: (tableShortcut) ->
    columns = []
    for columnName in @model.getColumnNames()
      columns.push("#{tableShortcut}.\"#{columnName}\"")
    columns.join()

module.exports = Save
