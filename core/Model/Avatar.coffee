module.exports = (bookshelf) ->
  bookshelf.Model.extend(
    tableName: "Avatars"
  ,
    createTable: ->
      bookshelf.knex.schema.createTable(@::tableName, (table) ->
        table.increments()
        table.string("_id").nullable() # may be null at first, while the MongoDB object is not yet created
        table.string("api").notNullable()
        table.string("uid").notNullable() # Native external API id
        table.string("name").notNullable()
        table.string("imageUrl").notNullable().defaultTo("")
        table.json("details", true).notNullable().defaultTo("{}")
        table.string("userId").notNullable()
        table.unique(["api", "uid", "userId"])
        table.index(["userId"])
      )
    dropTable: ->
      bookshelf.knex.schema.dropTableIfExists(@::tableName)
  )
