class CreatePtables < ActiveRecord::Migration
  def self.up
    create_table :ptables do |t|
      t.string :name,   :limit => 64, :null => false
      t.string :layout, :limit => 4096, :null => false
      t.references :operatingsystem
      t.timestamps
    end
    Ptable.create :name => "default", :layout =>"part /boot --fstype ext3 --size=100 --asprimary\npart /     --fstype ext3 --size=1024 --grow\npart swap  --recommended" 

    create_table :operatingsystems_ptables, :id => false do |t|
      t.references :ptable, :null => false
      t.references :operatingsystem, :null => false
    end


  end

  def self.down
    drop_table :ptables
    drop_table :operatingsystems_ptables
  end
end
