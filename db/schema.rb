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

ActiveRecord::Schema.define(version: 20160115205541) do

  create_table "actions", force: :cascade do |t|
    t.string   "parse_object_id",        limit: 255
    t.integer  "user_id",                limit: 4
    t.integer  "action_type",            limit: 4
    t.integer  "referenced_object_id",   limit: 4
    t.string   "referenced_object_type", limit: 255
    t.integer  "referenced_user_id",     limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "actions", ["action_type"], name: "index_actions_on_action_type", using: :btree
  add_index "actions", ["referenced_object_id"], name: "index_actions_on_referenced_object_id", using: :btree
  add_index "actions", ["referenced_object_type"], name: "index_actions_on_referenced_object_type", using: :btree
  add_index "actions", ["referenced_user_id"], name: "index_actions_on_referenced_user_id", using: :btree
  add_index "actions", ["user_id"], name: "index_actions_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.string   "name",            limit: 255, null: false
    t.integer  "order",           limit: 4,   null: false
    t.integer  "thumbnail_id",    limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.string   "name",            limit: 255, null: false
    t.integer  "geoname_id",      limit: 4
    t.integer  "state_id",        limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "cities", ["state_id"], name: "index_cities_on_state_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.text     "caption",         limit: 65535
    t.integer  "user_id",         limit: 4
    t.integer  "post_id",         limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "likes_count",     limit: 4,     default: 0, null: false
    t.integer  "reports_count",   limit: 4,     default: 0, null: false
  end

  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.string   "name",            limit: 255, null: false
    t.integer  "geoname_id",      limit: 4
    t.integer  "thumbnail_id",    limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "installations", force: :cascade do |t|
    t.string   "parse_object_id",            limit: 255
    t.string   "parse_installation_id",      limit: 255
    t.string   "app_identifier",             limit: 255
    t.string   "app_name",                   limit: 255
    t.string   "app_version",                limit: 255
    t.integer  "badge",                      limit: 4
    t.text     "device_token",               limit: 65535
    t.string   "device_token_last_modified", limit: 255
    t.string   "device_type",                limit: 255
    t.text     "installation_key",           limit: 65535
    t.string   "time_zone",                  limit: 255
    t.text     "google_ad_id",               limit: 65535
    t.boolean  "google_ad_id_limited"
    t.integer  "user_id",                    limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "media_files", force: :cascade do |t|
    t.text     "parse_url",  limit: 65535
    t.text     "url",        limit: 65535
    t.string   "name",       limit: 255,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "password_reset_codes", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "code",        limit: 255
    t.datetime "expire_date"
    t.boolean  "used"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "password_reset_codes", ["user_id"], name: "index_password_reset_codes_on_user_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.string   "name",            limit: 255
    t.string   "google_place_id", limit: 255
    t.float    "latitude",        limit: 24
    t.float    "longitude",       limit: 24
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.text     "caption",         limit: 65535
    t.integer  "category_id",     limit: 4
    t.integer  "user_id",         limit: 4
    t.integer  "place_id",        limit: 4
    t.integer  "photo_id",        limit: 4
    t.integer  "thumbnail_id",    limit: 4
    t.integer  "video_id",        limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "likes_count",     limit: 4,     default: 0, null: false
    t.integer  "reports_count",   limit: 4,     default: 0, null: false
    t.integer  "votes_count",     limit: 4,     default: 0, null: false
    t.integer  "comments_count",  limit: 4,     default: 0, null: false
  end

  add_index "posts", ["category_id"], name: "index_posts_on_category_id", using: :btree
  add_index "posts", ["place_id"], name: "index_posts_on_place_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "referral_codes", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "referral_codes", ["user_id"], name: "index_referral_codes_on_user_id", using: :btree

  create_table "rounds", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "access_token",    limit: 255
    t.integer  "user_id",         limit: 4
    t.integer  "installation_id", limit: 4
    t.datetime "expire_date"
    t.boolean  "expired"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "sessions", ["installation_id"], name: "index_sessions_on_installation_id", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "parse_object_id", limit: 255
    t.string   "name",            limit: 255, null: false
    t.integer  "geoname_id",      limit: 4
    t.integer  "country_id",      limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "states", ["country_id"], name: "index_states_on_country_id", using: :btree

  create_table "text_mentions", force: :cascade do |t|
    t.string   "parse_object_id",        limit: 255
    t.integer  "user_id",                limit: 4
    t.integer  "referenced_object_id",   limit: 4
    t.string   "referenced_object_type", limit: 255
    t.integer  "referenced_user_id",     limit: 4
    t.integer  "mention_start",          limit: 4
    t.integer  "mention_end",            limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "text_mentions", ["referenced_object_id"], name: "index_text_mentions_on_referenced_object_id", using: :btree
  add_index "text_mentions", ["referenced_user_id"], name: "index_text_mentions_on_referenced_user_id", using: :btree
  add_index "text_mentions", ["user_id"], name: "index_text_mentions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "parse_object_id",            limit: 255
    t.string   "username",                   limit: 255
    t.string   "name",                       limit: 255
    t.string   "password_digest",            limit: 255
    t.string   "email",                      limit: 255
    t.string   "first_name",                 limit: 255
    t.string   "last_name",                  limit: 255
    t.string   "gender",                     limit: 255
    t.text     "address",                    limit: 65535
    t.text     "street_address",             limit: 65535
    t.integer  "profile_picture_id",         limit: 4
    t.integer  "thumbnail_id",               limit: 4
    t.text     "facebook_token",             limit: 65535
    t.string   "facebook_id",                limit: 255
    t.datetime "facebook_token_expire_date"
    t.boolean  "email_verified"
    t.datetime "birthdate"
    t.string   "zip_code",                   limit: 255
    t.boolean  "verified"
    t.integer  "city_id",                    limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "posts_count",                limit: 4,     default: 0, null: false
    t.integer  "reports_count",              limit: 4,     default: 0, null: false
    t.integer  "followers_count",            limit: 4,     default: 0, null: false
    t.integer  "follows_count",              limit: 4,     default: 0, null: false
    t.integer  "blocks_count",               limit: 4
    t.text     "bio",                        limit: 65535
    t.string   "link",                       limit: 255
  end

  add_index "users", ["city_id"], name: "index_users_on_city_id", using: :btree

  create_table "winning_posts", force: :cascade do |t|
    t.integer  "round_id",   limit: 4
    t.integer  "post_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "order",      limit: 4
  end

  add_index "winning_posts", ["post_id"], name: "index_winning_posts_on_post_id", using: :btree
  add_index "winning_posts", ["round_id"], name: "index_winning_posts_on_round_id", using: :btree

  add_foreign_key "actions", "users"
  add_foreign_key "cities", "states"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "password_reset_codes", "users"
  add_foreign_key "posts", "categories"
  add_foreign_key "posts", "places"
  add_foreign_key "posts", "users"
  add_foreign_key "referral_codes", "users"
  add_foreign_key "sessions", "installations"
  add_foreign_key "sessions", "users"
  add_foreign_key "states", "countries"
  add_foreign_key "text_mentions", "users"
  add_foreign_key "users", "cities"
  add_foreign_key "winning_posts", "posts"
  add_foreign_key "winning_posts", "rounds"
end
