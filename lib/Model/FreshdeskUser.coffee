module.exports = (bookshelf) ->
  bookshelf.Model.extend(
    tableName: "FreshdeskUsers"
  ,
    createTable: ->
      bookshelf.knex.schema.createTable(@::tableName, (table) ->
        table.increments()
        table.bigInteger("uid").notNullable().unsigned() # Native Freshdesk user id
        table.string("address").nullable().defaultTo("")
        table.string("description").nullable()
        table.string("email").nullable()
        table.string("jobTitle").nullable()
        table.string("language").nullable()
        table.string("mobile").nullable()
        table.string("name").nullable()
        table.string("phone").nullable()
        table.string("timeZone").nullable()
        table.boolean("active").notNullable()
        table.boolean("isDeleted").notNullable()
        table.integer("avatarId").notNullable().references("id").inTable("Avatars").onUpdate("CASCADE").onDelete("CASCADE")
        table.unique(["uid", "avatarId"])
      )
  )
