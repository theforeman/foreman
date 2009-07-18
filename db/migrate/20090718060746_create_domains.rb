class CreateDomains < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.string :name, :default => "", :null => false
      t.string  :dnsserver
      t.string  :gateway,    :limit => 40
      t.string  :fullname,   :limit => 32
      t.timestamps
    end
  end

  def self.down
    drop_table :domains
  end
end
