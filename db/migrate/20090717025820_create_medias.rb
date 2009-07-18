class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.string :name,       :limit => 10, :default => "nfs", :null => false
      t.string :path
      t.integer :os_id
      t.timestamps
    end
    Media.create :name => "nfs"
    Media.create :name => "http"
  end

  def self.down
    drop_table :medias
  end
end
