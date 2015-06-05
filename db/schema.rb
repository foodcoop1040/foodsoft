# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150427084451) do

  create_table "article_categories", force: :cascade do |t|
    t.string "name",        default: "", null: false
    t.string "description"
  end

  add_index "article_categories", ["name"], name: "index_article_categories_on_name", unique: true

  create_table "article_prices", force: :cascade do |t|
    t.integer  "article_id"
    t.decimal  "price",         precision: 8, scale: 2, default: 0, null: false
    t.decimal  "tax",           precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit",       precision: 8, scale: 2, default: 0, null: false
    t.integer  "unit_quantity"
    t.datetime "created_at"
  end

  add_index "article_prices", ["article_id"], name: "index_article_prices_on_article_id"

  create_table "articles", force: :cascade do |t|
    t.string   "name",                                        default: "",   null: false
    t.integer  "supplier_id",                                 default: 0,    null: false
    t.integer  "article_category_id",                         default: 0,    null: false
    t.string   "unit",                                        default: "",   null: false
    t.string   "note"
    t.boolean  "availability",                                default: true, null: false
    t.string   "manufacturer"
    t.string   "origin"
    t.datetime "shared_updated_on"
    t.decimal  "price",               precision: 8, scale: 2
    t.float    "tax"
    t.decimal  "deposit",             precision: 8, scale: 2, default: 0
    t.integer  "unit_quantity",                               default: 1,    null: false
    t.string   "order_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "type"
    t.integer  "quantity",                                    default: 0
  end

  add_index "articles", ["article_category_id"], name: "index_articles_on_article_category_id"
  add_index "articles", ["name", "supplier_id"], name: "index_articles_on_name_and_supplier_id"
  add_index "articles", ["supplier_id"], name: "index_articles_on_supplier_id"
  add_index "articles", ["type"], name: "index_articles_on_type"

  create_table "assignments", force: :cascade do |t|
    t.integer "user_id",  default: 0,     null: false
    t.integer "task_id",  default: 0,     null: false
    t.boolean "accepted", default: false
  end

  add_index "assignments", ["user_id", "task_id"], name: "index_assignments_on_user_id_and_task_id", unique: true

  create_table "bank_accounts", force: :cascade do |t|
    t.string  "name",                                 default: "", null: false
    t.string  "iban",                                 default: "", null: false
    t.string  "description"
    t.decimal "balance",     precision: 12, scale: 2, default: 0,  null: false
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer "bank_account_id",                         default: 0, null: false
    t.date    "booking_date"
    t.date    "value_date"
    t.decimal "amount",          precision: 8, scale: 2, default: 0, null: false
    t.string  "booking_type"
    t.string  "booking_number"
    t.text    "text"
    t.string  "iban"
    t.string  "bic"
    t.string  "name"
    t.string  "reference"
    t.text    "receipt"
    t.binary  "image"
  end

  add_index "bank_transactions", ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id"

  create_table "deliveries", force: :cascade do |t|
    t.integer  "supplier_id"
    t.date     "delivered_on"
    t.datetime "created_at"
    t.text     "note"
  end

  add_index "deliveries", ["supplier_id"], name: "index_deliveries_on_supplier_id"

  create_table "documents", force: :cascade do |t|
    t.string   "name"
    t.binary   "content"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "documents", ["name"], name: "index_documents_on_name", unique: true

  create_table "financial_transactions", force: :cascade do |t|
    t.integer  "ordergroup_id",                         default: 0, null: false
    t.integer  "cost_type",                             default: 0, null: false
    t.decimal  "amount",        precision: 8, scale: 2, default: 0, null: false
    t.text     "note",                                              null: false
    t.integer  "user_id",                               default: 0, null: false
    t.datetime "created_on",                                        null: false
  end

  add_index "financial_transactions", ["ordergroup_id"], name: "index_financial_transactions_on_ordergroup_id"

  create_table "forem_categories", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "position",   default: 0
  end

  add_index "forem_categories", ["slug"], name: "index_forem_categories_on_slug", unique: true

  create_table "forem_forums", force: :cascade do |t|
    t.string  "name"
    t.text    "description"
    t.integer "category_id"
    t.integer "views_count", default: 0
    t.string  "slug"
    t.integer "position",    default: 0
  end

  add_index "forem_forums", ["slug"], name: "index_forem_forums_on_slug", unique: true

  create_table "forem_groups", force: :cascade do |t|
    t.string "name"
  end

  add_index "forem_groups", ["name"], name: "index_forem_groups_on_name"

  create_table "forem_memberships", force: :cascade do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  add_index "forem_memberships", ["group_id"], name: "index_forem_memberships_on_group_id"

  create_table "forem_moderator_groups", force: :cascade do |t|
    t.integer "forum_id"
    t.integer "group_id"
  end

  add_index "forem_moderator_groups", ["forum_id"], name: "index_forem_moderator_groups_on_forum_id"

  create_table "forem_posts", force: :cascade do |t|
    t.integer  "topic_id"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_to_id"
    t.string   "state",       default: "pending_review"
    t.boolean  "notified",    default: false
  end

  add_index "forem_posts", ["reply_to_id"], name: "index_forem_posts_on_reply_to_id"
  add_index "forem_posts", ["state"], name: "index_forem_posts_on_state"
  add_index "forem_posts", ["topic_id"], name: "index_forem_posts_on_topic_id"
  add_index "forem_posts", ["user_id"], name: "index_forem_posts_on_user_id"

  create_table "forem_subscriptions", force: :cascade do |t|
    t.integer "subscriber_id"
    t.integer "topic_id"
  end

  create_table "forem_topics", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",       default: false,            null: false
    t.boolean  "pinned",       default: false
    t.boolean  "hidden",       default: false
    t.datetime "last_post_at"
    t.string   "state",        default: "pending_review"
    t.integer  "views_count",  default: 0
    t.string   "slug"
  end

  add_index "forem_topics", ["forum_id"], name: "index_forem_topics_on_forum_id"
  add_index "forem_topics", ["slug"], name: "index_forem_topics_on_slug", unique: true
  add_index "forem_topics", ["state"], name: "index_forem_topics_on_state"
  add_index "forem_topics", ["user_id"], name: "index_forem_topics_on_user_id"

  create_table "forem_views", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "viewable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count",             default: 0
    t.string   "viewable_type"
    t.datetime "current_viewed_at"
    t.datetime "past_viewed_at"
  end

  add_index "forem_views", ["updated_at"], name: "index_forem_views_on_updated_at"
  add_index "forem_views", ["user_id"], name: "index_forem_views_on_user_id"
  add_index "forem_views", ["viewable_id"], name: "index_forem_views_on_viewable_id"

  create_table "group_order_article_quantities", force: :cascade do |t|
    t.integer  "group_order_article_id", default: 0, null: false
    t.integer  "quantity",               default: 0
    t.integer  "tolerance",              default: 0
    t.datetime "created_on",                         null: false
  end

  add_index "group_order_article_quantities", ["group_order_article_id"], name: "index_group_order_article_quantities_on_group_order_article_id"

  create_table "group_order_articles", force: :cascade do |t|
    t.integer  "group_order_id",                           default: 0, null: false
    t.integer  "order_article_id",                         default: 0, null: false
    t.integer  "quantity",                                 default: 0, null: false
    t.integer  "tolerance",                                default: 0, null: false
    t.datetime "updated_on",                                           null: false
    t.decimal  "result",           precision: 8, scale: 3
    t.decimal  "result_computed",  precision: 8, scale: 3
  end

  add_index "group_order_articles", ["group_order_id", "order_article_id"], name: "goa_index", unique: true
  add_index "group_order_articles", ["group_order_id"], name: "index_group_order_articles_on_group_order_id"
  add_index "group_order_articles", ["order_article_id"], name: "index_group_order_articles_on_order_article_id"

  create_table "group_orders", force: :cascade do |t|
    t.integer  "ordergroup_id",                              default: 0, null: false
    t.integer  "order_id",                                   default: 0, null: false
    t.decimal  "price",              precision: 8, scale: 2, default: 0, null: false
    t.integer  "lock_version",                               default: 0, null: false
    t.datetime "updated_on",                                             null: false
    t.integer  "updated_by_user_id"
  end

  add_index "group_orders", ["order_id"], name: "index_group_orders_on_order_id"
  add_index "group_orders", ["ordergroup_id", "order_id"], name: "index_group_orders_on_ordergroup_id_and_order_id", unique: true
  add_index "group_orders", ["ordergroup_id"], name: "index_group_orders_on_ordergroup_id"

  create_table "groups", force: :cascade do |t|
    t.string   "type",                                              default: "",    null: false
    t.string   "name",                                              default: "",    null: false
    t.string   "description"
    t.decimal  "account_balance",          precision: 12, scale: 2, default: 0,     null: false
    t.datetime "created_on",                                                        null: false
    t.boolean  "role_admin",                                        default: false, null: false
    t.boolean  "role_suppliers",                                    default: false, null: false
    t.boolean  "role_article_meta",                                 default: false, null: false
    t.boolean  "role_finance",                                      default: false, null: false
    t.boolean  "role_orders",                                       default: false, null: false
    t.datetime "deleted_at"
    t.string   "contact_person"
    t.string   "contact_phone"
    t.string   "contact_address"
    t.text     "stats"
    t.integer  "next_weekly_tasks_number",                          default: 8
    t.boolean  "ignore_apple_restriction",                          default: false
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true

  create_table "invites", force: :cascade do |t|
    t.string   "token",      default: "", null: false
    t.datetime "expires_at",              null: false
    t.integer  "group_id",   default: 0,  null: false
    t.integer  "user_id",    default: 0,  null: false
    t.string   "email",      default: "", null: false
  end

  add_index "invites", ["token"], name: "index_invites_on_token"

  create_table "invoices", force: :cascade do |t|
    t.integer  "supplier_id"
    t.integer  "delivery_id"
    t.integer  "order_id"
    t.string   "number"
    t.date     "date"
    t.string   "attachment_mime"
    t.binary   "attachment_data"
    t.date     "paid_on"
    t.text     "note"
    t.decimal  "amount",          precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit",         precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit_credit",  precision: 8, scale: 2, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoices", ["delivery_id"], name: "index_invoices_on_delivery_id"
  add_index "invoices", ["supplier_id"], name: "index_invoices_on_supplier_id"

  create_table "memberships", force: :cascade do |t|
    t.integer "group_id", default: 0, null: false
    t.integer "user_id",  default: 0, null: false
  end

  add_index "memberships", ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "reply_to"
    t.text     "recipients_ids"
    t.integer  "group_id"
    t.string   "subject",                        null: false
    t.text     "body"
    t.integer  "email_state",    default: 0,     null: false
    t.boolean  "private",        default: false
    t.datetime "created_at"
  end

  create_table "order_articles", force: :cascade do |t|
    t.integer "order_id",         default: 0, null: false
    t.integer "article_id",       default: 0, null: false
    t.integer "quantity",         default: 0, null: false
    t.integer "tolerance",        default: 0, null: false
    t.integer "units_to_order",   default: 0, null: false
    t.integer "lock_version",     default: 0, null: false
    t.integer "article_price_id"
    t.integer "units_billed"
    t.integer "units_received"
  end

  add_index "order_articles", ["order_id", "article_id"], name: "index_order_articles_on_order_id_and_article_id", unique: true
  add_index "order_articles", ["order_id"], name: "index_order_articles_on_order_id"

  create_table "order_comments", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at"
  end

  add_index "order_comments", ["order_id"], name: "index_order_comments_on_order_id"

  create_table "orders", force: :cascade do |t|
    t.integer  "supplier_id"
    t.text     "note"
    t.datetime "starts"
    t.datetime "ends"
    t.date     "expected_delivery_on"
    t.string   "state",                                        default: "open"
    t.integer  "lock_version",                                 default: 0,      null: false
    t.integer  "updated_by_user_id"
    t.decimal  "foodcoop_result",      precision: 8, scale: 2
    t.integer  "created_by_user_id"
  end

  add_index "orders", ["state"], name: "index_orders_on_state"

  create_table "page_versions", force: :cascade do |t|
    t.integer  "page_id"
    t.integer  "lock_version"
    t.text     "body"
    t.integer  "updated_by"
    t.integer  "redirect"
    t.integer  "parent_id"
    t.datetime "updated_at"
  end

  add_index "page_versions", ["page_id"], name: "index_page_versions_on_page_id"

  create_table "pages", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.string   "permalink"
    t.integer  "lock_version", default: 0
    t.integer  "updated_by"
    t.integer  "redirect"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["permalink"], name: "index_pages_on_permalink"
  add_index "pages", ["title"], name: "index_pages_on_title"

  create_table "periodic_task_groups", force: :cascade do |t|
    t.date     "next_task_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true

  create_table "stock_changes", force: :cascade do |t|
    t.integer  "delivery_id"
    t.integer  "order_id"
    t.integer  "stock_article_id"
    t.integer  "quantity",         default: 0
    t.datetime "created_at"
    t.integer  "stock_taking_id"
  end

  add_index "stock_changes", ["delivery_id"], name: "index_stock_changes_on_delivery_id"
  add_index "stock_changes", ["stock_article_id"], name: "index_stock_changes_on_stock_article_id"
  add_index "stock_changes", ["stock_taking_id"], name: "index_stock_changes_on_stock_taking_id"

  create_table "stock_takings", force: :cascade do |t|
    t.date     "date"
    t.text     "note"
    t.datetime "created_at"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "name",               default: "", null: false
    t.string   "address",            default: "", null: false
    t.string   "phone",              default: "", null: false
    t.string   "phone2"
    t.string   "fax"
    t.string   "email"
    t.string   "url"
    t.string   "contact_person"
    t.string   "customer_number"
    t.string   "delivery_days"
    t.string   "order_howto"
    t.string   "note"
    t.integer  "shared_supplier_id"
    t.string   "min_order_quantity"
    t.datetime "deleted_at"
    t.string   "shared_sync_method"
  end

  add_index "suppliers", ["name"], name: "index_suppliers_on_name", unique: true

  create_table "tasks", force: :cascade do |t|
    t.string   "name",                   default: "",    null: false
    t.string   "description"
    t.date     "due_date"
    t.boolean  "done",                   default: false
    t.integer  "workgroup_id"
    t.datetime "created_on",                             null: false
    t.datetime "updated_on",                             null: false
    t.integer  "required_users",         default: 1
    t.integer  "duration",               default: 1
    t.integer  "periodic_task_group_id"
  end

  add_index "tasks", ["due_date"], name: "index_tasks_on_due_date"
  add_index "tasks", ["name"], name: "index_tasks_on_name"
  add_index "tasks", ["workgroup_id"], name: "index_tasks_on_workgroup_id"

  create_table "users", force: :cascade do |t|
    t.string   "nick"
    t.string   "password_hash",          default: "",               null: false
    t.string   "password_salt",          default: "",               null: false
    t.string   "first_name",             default: "",               null: false
    t.string   "last_name",              default: "",               null: false
    t.string   "email",                  default: "",               null: false
    t.string   "phone"
    t.date     "birthday"
    t.string   "address",                default: "",               null: false
    t.string   "postalcode",             default: "",               null: false
    t.string   "city",                   default: "",               null: false
    t.string   "iban",                   default: "",               null: false
    t.datetime "created_on",                                        null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_expires"
    t.datetime "last_login"
    t.datetime "last_activity"
    t.boolean  "forem_admin",            default: false
    t.string   "forem_state",            default: "pending_review"
    t.boolean  "forem_auto_subscribe",   default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["nick"], name: "index_users_on_nick", unique: true

end
