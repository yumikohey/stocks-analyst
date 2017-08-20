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

ActiveRecord::Schema.define(version: 20170820040225) do

  create_table "form_thirteens", force: :cascade do |t|
    t.string "form_type"
    t.string "file_number"
    t.string "film_number"
    t.string "description"
    t.string "name_of_issue"
    t.string "title_of_class"
    t.string "cusip"
    t.integer "value"
    t.integer "shares_or_principle_amt"
    t.string "shares_or_principle"
    t.string "put_or_call"
    t.string "investment_desc"
    t.string "other_manager"
    t.integer "sole_number"
    t.integer "shared_number"
    t.integer "none_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cusip"], name: "index_form_thirteens_on_cusip"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quotes", force: :cascade do |t|
    t.string "symbol"
    t.date "date"
    t.float "open"
    t.float "high"
    t.float "low"
    t.float "close"
    t.integer "volume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_quotes_on_symbol"
  end

  create_table "splits", force: :cascade do |t|
    t.string "symbol"
    t.date "date"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_splits_on_symbol"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol"
    t.string "company_name"
    t.string "stock_exchange"
    t.string "cusip"
    t.string "industry"
    t.string "sector"
    t.string "ipo_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_stocks_on_symbol"
  end

end
