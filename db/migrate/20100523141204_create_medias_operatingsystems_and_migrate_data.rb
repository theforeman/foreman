class CreateMediasOperatingsystemsAndMigrateData < ActiveRecord::Migration
  def self.up
    create_table :medias_operatingsystems , :id => false do |t|
      t.references :media, :null => false
      t.references :operatingsystem, :null => false
    end

    media_hash = Hash.new
    Media.all.each do |medium|
      unless medium.operatingsystem_id.nil?
        os = Operatingsystem.find(medium.operatingsystem_id)
        media_hash[os] = medium
      end
    end

    media_hash.keys.each { |os| os.medias << media_hash[os] }

    remove_column :medias, :operatingsystem_id
  end

  def self.down
    add_column :medias, :operatingsystem_id, :integer
    drop_table :medias_operatingsystems
  end
end
