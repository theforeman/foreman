class AddIndexesOnImages < ActiveRecord::Migration[5.0]
  def up
    deduped = Image.group(:name, :compute_resource_id, :operatingsystem_id).pluck(Image.arel_table[:id].minimum)
    Image.where.not(id: deduped).each_with_index do |image, i|
      say "Found images with duplicate name #{image.name} on Compute Resource #{ComputeResource.unscoped.find(image.compute_resource_id)}!"
      say "Duplicates have been renamed, please check your setup to resolve the duplication."
      image.update_column(:name, "#{image.name}(Duplicate #{i})")
    end

    deduped = Image.group(:uuid, :compute_resource_id).pluck(Image.arel_table[:id].minimum)
    Image.where.not(id: deduped).each_with_index do |image, i|
      say "Found images with duplicate uuid #{image.uuid} on Compute Resource #{ComputeResource.unscoped.find(image.compute_resource_id)}!"
      say "Duplicates' uuids have been modified, please check your setup to resolve the duplication."
      image.update_column(:uuid, "#{image.uuid}(Duplicate #{i})")
    end

    add_index :images, [:name, :compute_resource_id, :operatingsystem_id], name: 'image_name_index', unique: true
    add_index :images, [:uuid, :compute_resource_id], name: 'image_uuid_index', unique: true
  end

  def down
    remove_index :images, name: 'image_name_index'
    remove_index :images, name: 'image_uuid_index'
  end
end
