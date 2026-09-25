class EnforceUniquePermissions < ActiveRecord::Migration[7.0]
  INDEX_NAME = 'index_permissions_on_name'.freeze

  # Fake models keep the migration independent of future model changes.
  class MigrationPermission < ApplicationRecord
    self.table_name = 'permissions'
  end

  class MigrationFiltering < ApplicationRecord
    self.table_name = 'filterings'
  end

  def up
    merge_duplicates
    add_index :permissions, :name, :unique => true, :name => INDEX_NAME
  end

  def down
    remove_index :permissions, :name => INDEX_NAME
  end

  private

  def merge_duplicates
    duplicate_names.each do |name|
      permissions = MigrationPermission.where(:name => name).order(:id).to_a
      retained = permissions.shift
      duplicates = permissions.map(&:id)

      merge_filterings(duplicates, retained.id)
      MigrationPermission.where(:id => duplicates).delete_all
    end
  end

  def duplicate_names
    MigrationPermission.group(:name).having('COUNT(*) > 1').pluck(:name)
  end

  def merge_filterings(permission_ids, retained_id)
    MigrationFiltering.where(:permission_id => permission_ids).find_each do |filtering|
      if MigrationFiltering.where(:filter_id => filtering.filter_id, :permission_id => retained_id).exists?
        filtering.delete
      else
        filtering.update_column(:permission_id, retained_id)
      end
    end
  end
end
