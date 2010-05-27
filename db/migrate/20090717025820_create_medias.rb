class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.string :name, :limit => 50, :default => "", :null => false
      t.string :path, :limit => 100, :default => "", :null => false
      t.references :operatingsystem
      t.timestamps
    end
    Media.create :name => "CentOS mirror", :path => "http://mirror.averse.net/centos/$major.$minor/os/$arch"
    Media.create :name => "Fedora Mirror", :path => "http://mirror.nus.edu.sg/fedora/releases/$major/Fedora/$arch/os/"
    Media.create :name => "RedHat Beta", :path => "http://ftp.redhat.com/pub/redhat/rhel/beta/$major/$arch/os"
    Media.create :name => "Ubuntu Mirror", :path => "http://sg.archive.ubuntu.com"

  end

  def self.down
    drop_table :medias
  end
end
