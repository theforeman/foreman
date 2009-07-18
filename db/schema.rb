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

ActiveRecord::Schema.define(:version => 20090718013153) do

  create_table "architectures", :force => true do |t|
    t.string   "name",       :limit => 10, :default => "x86_64", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fact_names", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fact_names", ["id"], :name => "index_fact_names_on_id"
  add_index "fact_names", ["name"], :name => "index_fact_names_on_name"

  create_table "fact_values", :force => true do |t|
    t.text     "value",        :default => "", :null => false
    t.integer  "fact_name_id",                 :null => false
    t.integer  "host_id",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fact_values", ["fact_name_id"], :name => "index_fact_values_on_fact_name_id"
  add_index "fact_values", ["host_id"], :name => "index_fact_values_on_host_id"
  add_index "fact_values", ["id"], :name => "index_fact_values_on_id"

  create_table "hosts", :force => true do |t|
    t.string   "mac",             :limit => 17,   :default => "",   :null => false
    t.string   "ip",              :limit => 15,   :default => "",   :null => false
    t.string   "root_pass",       :limit => 64,   :default => "",   :null => false
    t.integer  "domain_id",                                         :null => false
    t.integer  "architecture_id",                                   :null => false
    t.integer  "user_id",                                           :null => false
    t.integer  "edit_by_id",                                        :null => false
    t.integer  "gi_id",                                             :null => false
    t.integer  "media_id",                                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "build",                           :default => true, :null => false
    t.string   "serial",          :limit => 12,   :default => "",   :null => false
    t.integer  "model_id"
    t.integer  "subnet_id",                       :default => 0,    :null => false
    t.integer  "environment_id",                  :default => 3,    :null => false
    t.text     "comment"
    t.text     "disk"
    t.string   "puppetmaster"
    t.string   "services",        :limit => 1024
    t.string   "sp_mac",          :limit => 17
    t.string   "sp_ip",           :limit => 15
    t.string   "sp_name",         :limit => 16
    t.string   "sp_pass",         :limit => 64
    t.integer  "sp_subnet_id"
    t.integer  "deployment_id"
    t.integer  "ptable_id"
    t.datetime "installed_at"
    t.integer  "puppet_status",                   :default => 0,    :null => false
    t.boolean  "unconfigured",                    :default => true, :null => false
    t.string   "name",                                              :null => false
    t.string   "environment"
    t.datetime "last_compile"
    t.datetime "last_freshcheck"
    t.datetime "last_report"
  end

  create_table "medias", :force => true do |t|
    t.string   "name",       :limit => 10, :default => "nfs", :null => false
    t.string   "path"
    t.integer  "os_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "os", :force => true do |t|
    t.string   "major",           :limit => 5,  :default => "", :null => false
    t.string   "name",            :limit => 64
    t.string   "minor",           :limit => 16
    t.string   "nameindicator",   :limit => 3
    t.integer  "architecture_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
