# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080915204910) do

  create_table "delivery_receipts", :force => true do |t|
    t.integer  "short_message_id"
    t.string   "tracking_id",      :limit => 32
    t.string   "status",           :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delivery_receipts", ["tracking_id"], :name => "index_delivery_receipts_on_tracking_id"
  add_index "delivery_receipts", ["short_message_id"], :name => "index_delivery_receipts_on_short_message_id"

  create_table "short_messages", :force => true do |t|
    t.string   "destination"
    t.text     "body"
    t.string   "originator"
    t.string   "originator_type"
    t.string   "message_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
