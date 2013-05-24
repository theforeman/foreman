class CreatePtables < ActiveRecord::Migration
  class Ptable < ActiveRecord::Base; end
  def self.up
    create_table :ptables do |t|
      t.string :name,   :limit => 64, :null => false
      t.string :layout, :limit => 4096, :null => false
      t.references :operatingsystem
      t.timestamps
    end
    Ptable.create :name => "RedHat default", :layout =>"zerombr\nclearpart --all --initlabel\nautopart"
    Ptable.create :name => "Ubuntu default", :layout =>"d-i partman-auto/disk string /dev/sda\nd-i partman-auto/method string regular\nd-i partman-auto/init_automatically_partition select Guided - use entire disk\nd-i partman/confirm_write_new_label boolean true\nd-i partman/choose_partition select \\\nFinish partitioning and write changes to disk\nd-i partman/confirm boolean true\n"

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
