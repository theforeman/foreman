class CreateMedia < ActiveRecord::Migration
  class Medium < ActiveRecord::Base; end
  def self.up
    create_table :media do |t|
      t.string :name, :limit => 50, :default => "", :null => false
      t.string :path, :limit => 100, :default => "", :null => false
      t.references :operatingsystem
      t.timestamps
    end
    Medium.create :name => "CentOS mirror", :path => "http://mirror.averse.net/centos/$major.$minor/os/$arch"
    Medium.create :name => "Fedora Mirror", :path => "http://mirror.nus.edu.sg/fedora/releases/$major/Fedora/$arch/os/"
    Medium.create :name => "Ubuntu Mirror", :path => "http://sg.archive.ubuntu.com"

  end

  def self.down
    drop_table :media
  end
end
