class CreateHypervisors < ActiveRecord::Migration
  def self.up
    create_table :hypervisors do |t|
      t.string :name
      t.string :uri
      t.string :kind
      t.timestamps
    end
  end

  def self.down
    drop_table :hypervisors
  end
end
