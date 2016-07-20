class CreateDomains < ActiveRecord::Migration[4.2]
  def up
    create_table :domains do |t|
      t.string :name, :default => "", :null => false, :limit => 255
      t.string  :dnsserver,  :limit => 255
      t.string  :gateway,    :limit => 40
      t.string  :fullname,   :limit => 32
      t.timestamps null: true
    end
  end

  def down
    drop_table :domains
  end
end
