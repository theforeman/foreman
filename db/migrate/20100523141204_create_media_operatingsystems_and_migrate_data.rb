class CreateMediaOperatingsystemsAndMigrateData < ActiveRecord::Migration[4.2]
  class Medium < ApplicationRecord; end

  def up
    medium_hash = {}
    Medium.all.each do |medium|
      unless medium.operatingsystem_id.nil?
        if Operatingsystem.exists?(medium.operatingsystem_id)
          os = Operatingsystem.find(medium.operatingsystem_id)
          medium_hash[os] = medium
        else
          say "skipped #{medium}"
        end
      end
    end

    create_table :media_operatingsystems, :id => false do |t|
      t.references :medium, :null => false
      t.references :operatingsystem, :null => false
    end

    medium_hash.keys.each { |os| os.media << medium_hash[os] }

    remove_column :media, :operatingsystem_id
    Medium.reset_column_information
  end

  def down
    add_column :media, :operatingsystem_id, :integer
    drop_table :media_operatingsystems
  end
end
