class CorrectMedia < ActiveRecord::Migration[4.2]
  def up
    if table_exists? :medias
      if table_exists? :medias_operatingsystems
        rename_column :medias_operatingsystems, :media_id, :medium_id
        rename_table :medias_operatingsystems, :media_operatingsystems
      end

      change_table :hosts do |t|
        t.remove_index :name => :host_media_id_ix
        t.rename :media_id, :medium_id
        t.index :medium_id, :name => :host_medium_id_ix
      end

      rename_table :medias, :media
    end
  end

  def down
    if table_exists? :media
      if table_exists? :media_operatingsystems
        rename_column :medias_operatingsystems, :medium_id, :media_id
        rename_table :media_operatingsystems, :medias_operatingsystems
      end

      change_table :hosts do |t|
        t.remove_index :name => :host_medium_id_ix
        t.rename :medium_id, :media_id
        t.index :media_id, :name => :host_media_id_ix
      end

      rename_table :media, :medias
    end
  end
end
