# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_06_07_154506) do
  create_table "drawings", force: :cascade do |t|
    t.string "name"
    t.string "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "rgb"
  end

  create_table "reflections", force: :cascade do |t|
    t.string "rgb"
    t.string "summary"
    t.datetime "created_at"
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "id"
    t.string "password_hash"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
