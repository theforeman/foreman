class AddUbuntuCustomLvmPtable < ActiveRecord::Migration
  def self.up
    Ptable.create :name => "Ubuntu custom LVM", :layout => <<EOF
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string lvm

d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

d-i partman-auto/init_automatically_partition \\
	select Guided - use entire disk and set up LVM

d-i partman-auto-lvm/guided_size string max
d-i partman-auto-lvm/new_vg_name string vg00

d-i partman-auto/expert_recipe string                         \\
      boot-root ::                                            \\
              64 128 128 ext3                                 \\
                      $primary{ } $bootable{ }                \\
                      method{ format } format{ }              \\
                      use_filesystem{ } filesystem{ ext4 }    \\
                      mountpoint{ /boot }                     \\
              .                                               \\
              128 512 200% linux-swap                         \\
                      method{ swap } format{ }                \\
              .                                               \\
              512 512 512 ext3                                \\
                      method{ format } format{ } $lvmok{ }    \\
                      use_filesystem{ } filesystem{ ext4 }    \\
                      mountpoint{ / }                         \\
              .                                               \\
              256 256 256 ext3                                \\
                      method{ format } format{ } $lvmok{ }    \\
                      use_filesystem{ } filesystem{ ext4 }    \\
                      mountpoint{ /home }                     \\
              .                                               \\
              256 512 512 ext3                                \\
                      method{ format } format{ } $lvmok{ }    \\
                      use_filesystem{ } filesystem{ ext4 }    \\
                      mountpoint{ /tmp }                      \\
              .                                               \\
              2048 4096 4096 ext3                             \\
                      method{ format } format{ } $lvmok{ }    \\
                      use_filesystem{ } filesystem{ ext4 }    \\
                      mountpoint{ /usr }                      \\
              .                                               \\
              2048 4096 -1 ext3                               \\
                      method{ format } format{ } $lvmok{ }    \\
                      use_filesystem{ } filesystem{ ext4 }    \\
                      mountpoint{ /var }                      \\
              .

d-i partman/default_filesystem string ext4

d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
EOF
  end

  def self.down
    Ptable.first(:conditions => "name = 'Ubuntu custom LVM'").delete
  end
end
