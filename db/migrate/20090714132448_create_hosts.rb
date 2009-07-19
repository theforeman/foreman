class CreateHosts < ActiveRecord::Migration
  def self.up
    #TODO: create a migration if puppets database already exists!
    create_table :hosts do |t|
      t.string   "mac",             :limit => 17,   :default => ""
      t.string   "ip",              :limit => 15,   :default => ""
      t.string   "root_pass",       :limit => 64
      t.integer  "domain_id"
      t.integer  "architecture_id"
      t.integer  "user_id"
      t.integer  "last_updated_by_id"
      t.integer  "os_id"
      t.integer  "media_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "build",           :default => true
      t.string   "serial",          :limit => 12
      t.integer  "model_id"
      t.integer  "subnet_id"
      t.integer  "environment_id"
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
      t.integer  "puppet_status"
      t.boolean  "unconfigured",    :default => true

      #compatibility to existing puppet schema
      t.string :name, :null => false
      t.string :environment
      t.datetime :last_compile
      t.datetime :last_freshcheck
      t.datetime :last_report

      t.timestamps
    end
  end

  def self.down
    drop_table :hosts
  end
end
