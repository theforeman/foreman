class CreateHosts < ActiveRecord::Migration
  def self.up

    # Copied from the Puppet schema to replace loading their schema directly
    create_table :hosts do |t|
      t.column :name, :string, :null => false
      t.column :ip, :string
      t.column :environment, :text
      t.column :last_compile, :datetime
      t.column :last_freshcheck, :datetime
      t.column :last_report, :datetime
      #Use updated_at to automatically add timestamp on save.
      t.column :updated_at, :datetime
      t.column :source_file_id, :integer
      t.column :created_at, :datetime
    end
    add_index :hosts, :source_file_id, :integer => true
    add_index :hosts, :name

    create_table :fact_names do |t|
      t.column :name, :string, :null => false
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
    end
    add_index :fact_names, :name

    create_table :fact_values do |t|
      t.column :value, :text, :null => false
      t.column :fact_name_id, :integer, :null => false
      t.column :host_id, :integer, :null => false
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
    end
    add_index :fact_values, :fact_name_id, :integer => true
    add_index :fact_values, :host_id, :integer => true

    add_column :hosts, :mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_ip, :string, :limit => 15, :default => ""
    add_column :hosts, :sp_name, :string, :default => ""
    add_column :hosts, :root_pass, :string, :limit => 64
    add_column :hosts, :serial, :string, :limit => 12
    add_column :hosts, :puppetmaster, :string
    add_column :hosts, :puppet_status, :integer,  :null => false, :default => 0

    add_column :hosts, :domain_id, :integer
    add_column :hosts, :architecture_id, :integer
    add_column :hosts, :operatingsystem_id, :integer
    add_column :hosts, :environment_id, :integer
    add_column :hosts, :subnet_id, :integer
    add_column :hosts, :sp_subnet_id, :integer
    add_column :hosts, :ptable_id, :integer
    add_column :hosts, :medium_id, :integer
    add_column :hosts, :build, :boolean, :default => true
    add_column :hosts, :comment, :text
    add_column :hosts, :disk, :text

    add_column :hosts, :installed_at, :datetime
  end

  def self.down
    drop_table :hosts
    drop_table :fact_names
    drop_table :fact_values
  end
end
