class AddSolarisDisks < ActiveRecord::Migration
  def self.up
    disk = Ptable.create :name => "Solaris small disk c1t0", :layout =>"filesys c1t0d0s0 7000 /\nfilesys c1t0d0s1 1000 swap\nfilesys c1t0d0s3 15 unnamed\nfilesys c1t0d0s7 free /tmp2\n"
    disk.operatingsystems = Operatingsystem.find_all_by_type "Solaris"
    disk = Ptable.create :name => "Solaris small disk c0t0", :layout =>"filesys c0t0d0s0 7000 /\nfilesys c0t0d0s1 1000 swap\nfilesys c0t0d0s3 15 unnamed\nfilesys c0t0d0s7 free /tmp2\n"
    disk.operatingsystems = Operatingsystem.find_all_by_type "Solaris"
    disk = Ptable.create :name => "Solaris medium disk mirrored", :layout => "filesys mirror:d10 c1t0d0s0 c1t1d0s0 16000 /\nfilesys mirror:d20 c1t0d0s1 c1t1d0s1 8000 swap\nfilesys mirror:d40 c1t0d0s4 c1t1d0s4 free /var/tmp\nmetadb c1t0d0s7 size 8192 count 3\nmetadb c1t1d0s7 size 8192 count 3\n"
    disk.operatingsystems = Operatingsystem.find_all_by_type "Solaris"
  end

  def self.down
    Ptable.find_by_name("Solaris medium disk mirrored").destroy
    Ptable.find_by_name("Solaris small disk c0t0").destroy
    Ptable.find_by_name("Solaris small disk c1t0").destroy
  end
end
