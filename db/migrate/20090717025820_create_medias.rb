class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.string :name, :limit => 50, :default => "", :null => false
      t.string :path, :limit => 100, :default => "", :null => false
      t.integer :operatingsystem_id
      t.timestamps
    end
    Media.create :name => "CentOS 5 mirror", :path => "http://mirror.averse.net/centos/5.3/os/$arch"
    Media.create :name => "Fedora 11 Mirror", :path => "http://mirror.nus.edu.sg/fedora/releases/11/Fedora/$arch/os/"
  end

  def self.down
    drop_table :medias
  end
end
