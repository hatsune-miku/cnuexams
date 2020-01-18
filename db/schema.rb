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

ActiveRecord::Schema.define(version: 20200118034150) do

  create_table "auths", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "authorizer"
    t.string "authorizee"
    t.string "auth_code"
    t.integer "remaining"
  end

  create_table "corps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "since"
    t.string "website"
    t.string "legal_entity"
    t.string "tel"
    t.string "fax"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customcates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.float "perportion", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_customcates_on_name", unique: true
  end

  create_table "exam_limits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "username"
    t.integer "exam_id"
    t.integer "current"
    t.integer "locked_before"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "last_login"
    t.integer "fail_count", default: 0
  end

  create_table "exams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "name", limit: 16777215
    t.float "requirement", limit: 53
    t.integer "retestable"
    t.integer "time_limit"
    t.integer "limit", default: 0
    t.boolean "public", default: false
    t.integer "policy", default: 0
  end

  create_table "hotels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "belong"
    t.string "latlng"
    t.string "tel"
    t.integer "cate"
    t.string "attrs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "institutes", primary_key: "name", id: :string, limit: 64, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.float "mathp", limit: 53
    t.float "artp", limit: 53
    t.float "generalp", limit: 53
    t.integer "kind"
  end

  create_table "members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "role"
    t.integer "belong"
    t.string "tel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meta", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "record", limit: 16777215
  end

  create_table "preferences", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 64
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "summary", limit: 16777215
    t.text "options", limit: 16777215
    t.text "answer", limit: 16777215
    t.float "score", limit: 53
    t.integer "essential"
    t.integer "kind"
    t.integer "cate"
    t.string "exam"
    t.string "label"
  end

  create_table "records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "username"
    t.string "question_ids"
    t.string "ans"
    t.string "real_ans"
    t.integer "time_elapsed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exam_id"
    t.float "score", limit: 24
    t.integer "hit"
    t.integer "miss"
  end

  create_table "test", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "name", limit: 16777215
  end

  create_table "users", primary_key: "username", id: :string, limit: 64, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "password", limit: 16777215
    t.text "name", limit: 16777215
    t.text "institute", limit: 16777215
    t.text "major", limit: 16777215
    t.integer "status"
    t.text "session_id", limit: 16777215
    t.text "question_ids", limit: 16777215
    t.integer "exam_id"
    t.integer "time_started"
    t.integer "time_submitted"
    t.string "saved_answers"
  end

end
