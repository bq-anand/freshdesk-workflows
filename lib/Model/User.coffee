_ = require "underscore"

module.exports = (bookshelf) ->
  bookshelf.Model.extend(
    tableName: "FreshdeskUsers"
    hasTimestamps: ['_createdAt', '_updatedAt']
  ,
    buildTable: (table) ->
      table.increments()
      table.string("address").nullable().defaultTo("")
      table.bigInteger("customer_id").nullable()
      table.bigInteger("company_id").nullable()
      table.bigInteger("external_id").nullable()
      table.string("fb_profile_id").nullable()
      table.string("description").nullable()
      table.string("email").nullable()
      table.string("job_title").nullable()
      table.string("language").nullable()
      table.string("mobile").nullable()
      table.string("name").nullable()
      table.string("phone").nullable()
      table.string("time_zone").nullable()
      table.string("twitter_id").nullable()
      table.json("custom_field", true).nullable()
      table.boolean("helpdesk_agent").notNullable()
      table.boolean("active").notNullable()
      table.boolean("deleted").notNullable()
      table.dateTime("created_at").notNullable()  # native Freshdesk created_at
      table.dateTime("updated_at").notNullable()  # native Freshdesk updated_at
      table.bigInteger("_uid").notNullable().unsigned() # native Freshdesk id
      table.string("_avatarId").notNullable()
      table.dateTime("_createdAt").notNullable()
      table.dateTime("_updatedAt").notNullable()
      table.unique(["id", "_avatarId"])
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
