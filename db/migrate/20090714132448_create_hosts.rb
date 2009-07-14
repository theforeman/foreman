class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.string   "mac",             :limit => 17,   :default => "",         :null => false
      t.string   "ip",              :limit => 15,   :default => "",         :null => false
      t.string   "hostname",        :limit => 16,   :default => ""
      t.string   "root_pass",       :limit => 64,   :default => "",         :null => false
      t.integer  "domain_id",                                               :null => false
      t.integer  "architecture_id",                                         :null => false
      t.integer  "user_id",                                                 :null => false
      t.integer  "edit_by_id",                                              :null => false
      t.integer  "gi_id",                                                   :null => false
      t.integer  "media_id",                                                :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "build",                           :default => true,       :null => false
      t.string   "serial",          :limit => 12,   :default => "",         :null => false
      t.integer  "model_id"
      t.integer  "subnet_id",                       :default => 0,          :null => false
      t.integer  "hosttype_id",                                             :null => false
      t.integer  "environment_id",                  :default => 3,          :null => false
      t.text     "comment"
      t.text     "disk"
      t.string   "puppetmaster"                         
      t.string   "services",        :limit => 1024
      t.string   "sp_mac",          :limit => 17
      t.string   "sp_ip",           :limit => 15
      t.string   "sp_hostname",     :limit => 16
      t.string   "sp_pass",         :limit => 64        
      t.integer  "sp_subnet_id"
      t.integer  "deployment_id"
      t.integer  "ptable_id"
      t.datetime "last_connect"
      t.datetime "installed_at"
      t.integer  "puppet_status",                   :default => 0,          :null => false
      t.boolean  "unconfigured",                    :default => true,       :null => false


      t.timestamps
    end
  end

  def self.down
    drop_table :hosts
  end
end
