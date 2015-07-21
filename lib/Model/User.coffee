_ = require "underscore"
helper = require "../../core/helper/model"

module.exports = (bookshelf) ->
  bookshelf.Model.extend(
    tableName: "FreshdeskUsers"
    hasTimestamps: ['_createdAt', '_updatedAt']
  ,
    _.extend helper(bookshelf),
      buildTable: (table) ->
        table.increments()
        table.string("address").nullable().defaultTo("")
        table.integer("customer_id").nullable()
        table.integer("company_id").nullable()
        table.integer("external_id").nullable()
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
        table.dateTime("created_at").notNullable()  # native Freshdesk _createdAt
        table.dateTime("updated_at").notNullable()  # native Freshdesk _updatedAt
        table.bigInteger("_uid").notNullable().unsigned() # native Freshdesk id
        table.string("_avatarId").notNullable()
        table.dateTime("_createdAt").notNullable()
        table.dateTime("_updatedAt").notNullable()
        table.unique(["_uid", "_avatarId"])
  )
