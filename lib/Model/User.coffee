_ = require "underscore"

module.exports = (bookshelf) ->
  bookshelf.Model.extend(
    tableName: "FreshdeskUsers"
    hasTimestamps: ['backendCreatedAt', 'backendUpdatedAt']
  ,
    buildTable: (table) ->
      table.increments()
      table.bigInteger("uid").notNullable().unsigned() # native Freshdesk id
      table.dateTime("createdAt").notNullable()  # native Freshdesk created_at
      table.dateTime("updatedAt").notNullable()  # native Freshdesk updated_at
      table.dateTime("backendCreatedAt").notNullable()
      table.dateTime("backendUpdatedAt").notNullable()
      table.string("address").nullable().defaultTo("")
      table.bigInteger("customerId").nullable()
      table.bigInteger("companyId").nullable()
      table.bigInteger("externalId").nullable()
      table.string("fbProfileId").nullable()
      table.string("description").nullable()
      table.string("email").nullable()
      table.string("jobTitle").nullable()
      table.string("language").nullable()
      table.string("mobile").nullable()
      table.string("name").nullable()
      table.string("phone").nullable()
      table.string("timeZone").nullable()
      table.string("twitterId").nullable()
      table.json("customField", true).nullable()
      table.boolean("isHelpdeskAgent").notNullable()
      table.boolean("isActive").notNullable()
      table.boolean("isDeleted").notNullable()
      table.integer("avatarId").notNullable().references("id").inTable("Avatars").onUpdate("CASCADE").onDelete("CASCADE")
      table.unique(["uid", "avatarId"])
    createTable: ->

      bookshelf.knex.schema.createTable(@::tableName, @buildTable.bind(@))
    getColumns: ->
      client = bookshelf.knex.schema.client
      builder = new client.TableBuilder(client, "create", @::tableName, @buildTable.bind(@))
      builder._fn.call(builder, builder)
      compiler = new client.TableCompiler(client, builder)
      for column in compiler.grouped.columns
        new client.ColumnCompiler(client, compiler, column.builder)
  )
