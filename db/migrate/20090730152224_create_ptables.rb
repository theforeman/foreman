class CreatePtables < ActiveRecord::Migration
  class Ptable < ActiveRecord::Base; end
  def self.up
    create_table :ptables do |t|
      t.string :name,   :limit => 64, :null => false
      t.string :layout, :limit => 4096, :null => false
      t.references :operatingsystem
      t.timestamps
    end
    Ptable.create :name => "RedHat default", :layout =>"zerombr\nclearpart --all --initlabel\nautopart\n"
    Ptable.create :name => "Ubuntu default", :layout => <<EOF
<% if @host.params['install-disk'] -%>
d-i partman-auto/disk string <%= @host.params['install-disk'] %>
<% else -%>
d-i partman-auto/disk string /dev/sda /dev/vda
<% end -%>

d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

d-i partman-auto/method string regular
d-i partman-auto/init_automatically_partition select Guided - use entire disk
d-i partman-auto/choose_recipe All files in one partition
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition select \
Finish partitioning and write changes to disk
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
EOF

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
