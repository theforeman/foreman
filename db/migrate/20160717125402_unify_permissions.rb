class UnifyPermissions < ActiveRecord::Migration[4.2]
  def up
    names = Permission.group(:name).having("count(*) > 1").pluck(:name)
    names.each do |name|
      dup_permissions = Permission.where(:name => name).order(:id).pluck(:id).to_a
      # Keeps one of the duplicates
      saved_permission = dup_permissions.pop
      Filtering.where(:permission_id => dup_permissions).update_all(:permission_id => saved_permission)
      Permission.where(:id => dup_permissions).delete_all
    end

    add_index :permissions, :name, :unique => true
  end

  def down
    remove_index :permissions, :name, :unique => true
  end
end
