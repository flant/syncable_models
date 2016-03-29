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

ActiveRecord::Schema.define(version: 20160327154807) do

  create_table "projects", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "uuid",        null: false
    t.datetime "deleted_at"
    t.string   "external_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "projects", ["uuid"], name: "index_projects_on_uuid", unique: true

  create_table "syncs", force: :cascade do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "destination",                         null: false
    t.string   "subject_external_id",                 null: false
    t.boolean  "subject_destroyed",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "syncs", ["destination"], name: "index_syncs_on_destination"
  add_index "syncs", ["subject_external_id", "subject_destroyed"], name: "index_syncs_on_subject_external_id_and_subject_destroyed"
  add_index "syncs", ["subject_id", "subject_type", "destination"], name: "index_syncs_on_subject_id_and_subject_type_and_destination"

  create_table "teams", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "external_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
