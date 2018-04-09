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

ActiveRecord::Schema.define(version: 20180408181801) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cachelines", force: :cascade do |t|
    t.string "url_minus_auth"
    t.text "body"
    t.integer "http_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url_minus_auth"], name: "index_cachelines_on_url_minus_auth", unique: true
  end

  create_table "causes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_causes_on_parent_id"
  end

  create_table "causes_charities", id: false, force: :cascade do |t|
    t.bigint "cause_id"
    t.bigint "charity_id"
    t.index ["cause_id"], name: "index_causes_charities_on_cause_id"
    t.index ["charity_id"], name: "index_causes_charities_on_charity_id"
  end

  create_table "charities", force: :cascade do |t|
    t.string "name"
    t.string "ein"
    t.text "description"
    t.float "score_overall"
    t.integer "stars_overall"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["ein"], name: "index_charities_on_ein", unique: true
    t.index ["website"], name: "index_charities_on_website"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.datetime "disabled_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
