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

ActiveRecord::Schema[7.2].define(version: 2025_06_30_225309) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crawler_pages", id: :serial, force: :cascade do |t|
    t.integer "result_page_id"
    t.string "URL"
    t.string "name"
    t.string "ancestry"
    t.integer "domain_crawler_id"
    t.date "download_date"
    t.index ["ancestry"], name: "index_crawler_pages_on_ancestry"
    t.index ["domain_crawler_id"], name: "index_crawler_pages_on_domain_crawler_id"
  end

  create_table "crawler_ranges", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "begin_id"
    t.integer "end_id"
    t.index ["user_id"], name: "index_crawler_ranges_on_user_id"
  end

  create_table "display_nodes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "crawler_page_id"
    t.index ["crawler_page_id"], name: "index_display_nodes_on_crawler_page_id"
    t.index ["user_id"], name: "index_display_nodes_on_user_id"
  end

  create_table "domain_crawlers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "permissions"
    t.integer "permissions_group_id"
    t.integer "version", default: 1
    t.string "domain_home_page"
    t.string "short_name"
    t.integer "crawler_page_id"
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["crawler_page_id"], name: "index_domain_crawlers_on_crawler_page_id"
  end

  create_table "group_elements", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "note"
    t.integer "group_name_id"
    t.integer "search_result_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "paragraph_id"
    t.index ["group_name_id"], name: "index_group_elements_on_group_name_id"
    t.index ["paragraph_id"], name: "group_elements_paragraph_id_ix"
    t.index ["search_result_id"], name: "index_group_elements_on_search_result_id"
  end

  create_table "group_names", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "ancestry"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "paragraphs", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "result_page_id"
    t.text "deaccented_content", default: ""
    t.boolean "accented", default: false
    t.index ["result_page_id"], name: "result_page_id_ix"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prelim_results", id: :serial, force: :cascade do |t|
    t.integer "search_query_id"
    t.integer "sentence_id"
    t.index ["search_query_id"], name: "index_prelim_results_on_search_query_id"
  end

  create_table "regex_instances", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "regex_templated_id"
    t.string "argument"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "regex_templates", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "expression"
    t.string "arg_names"
    t.text "help"
    t.string "join_code"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "result_pages", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "hash_value"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "crawler_page_id"
    t.text "content"
    t.index ["hash_value"], name: "hash_value_ix"
  end

  create_table "save_my_sqls", id: :serial, force: :cascade do |t|
    t.text "save_str"
  end

  create_table "save_sqls", id: :serial, force: :cascade do |t|
    t.text "sql_str"
  end

  create_table "search_queries", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "start_index"
    t.integer "view_priority"
    t.string "first_search_term"
    t.string "second_search_term"
    t.string "third_search_term"
    t.string "fourth_search_term"
    t.integer "word_separation"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_search_queries_on_user_id"
  end

  create_table "search_results", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "permissions"
    t.integer "permissions_group_id"
    t.integer "search_query_id"
    t.text "highlighted_result"
    t.string "hash_value"
    t.integer "sentence_id"
    t.integer "crawler_page_id"
    t.boolean "hidden", default: false
    t.boolean "selected", default: false
    t.integer "begin_display_paragraph_id"
    t.integer "end_display_paragraph_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["search_query_id"], name: "search_query_id_ix"
  end

  create_table "sentences", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "paragraph_id"
    t.text "deaccented_content", default: ""
    t.boolean "accented", default: false
    t.index ["paragraph_id"], name: "paragraph_id_ix"
  end

  create_table "super_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_super_users_on_user_id"
  end

  create_table "user_paragraphs", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "paragraph_id"
    t.index ["paragraph_id"], name: "index_user_paragraphs_on_paragraph_id"
    t.index ["user_id"], name: "index_user_paragraphs_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "second_name"
    t.string "password_digest"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "auth_token"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at", precision: nil
    t.integer "group_id"
    t.integer "search_query_id"
    t.boolean "guest"
  end

  create_table "word_pairs", id: :serial, force: :cascade do |t|
    t.bigint "word_multiple"
    t.integer "separation"
    t.integer "result_page_id"
    t.integer "sentence_id"
    t.index ["result_page_id"], name: "index_word_pairs_on_result_page_id"
    t.index ["sentence_id"], name: "sentence_id_ix"
    t.index ["word_multiple"], name: "word_multiple_id_ix"
  end

  create_table "word_singletons", id: :serial, force: :cascade do |t|
    t.integer "word_id"
    t.integer "result_page_id"
    t.integer "sentence_id"
    t.integer "paragraph_id"
    t.index ["paragraph_id"], name: "word_singletons_paragraph_id_ix"
    t.index ["result_page_id"], name: "index_word_singletons_on_result_page_id"
    t.index ["sentence_id"], name: "ws_sentence_id_ix"
    t.index ["word_id"], name: "word_id_ix"
  end

  create_table "words", primary_key: "word_name", id: :serial, force: :cascade do |t|
    t.integer "id_value"
    t.integer "word_prime"
    t.index ["id_value"], name: "index_words_on_id_value"
    t.index ["word_prime"], name: "index_words_on_word_prime"
  end
end
