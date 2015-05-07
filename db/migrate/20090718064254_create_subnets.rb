class CreateSubnets < ActiveRecord::Migration
  def up
    create_table :subnets do |t|
      t.string   :number,     :limit => 15
      t.string   :mask,       :limit => 15
      t.references  :domain
      t.integer  :priority
      t.string   :ranges,     :limit => 512
      t.text     :name
      t.string   :vlanid,     :limit => 10
      t.timestamps
    end
  end

  def down
    drop_table :subnets
  end
end
