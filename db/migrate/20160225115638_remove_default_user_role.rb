class RemoveDefaultUserRole < ActiveRecord::Migration[4.2]
  def up
    role = Role.where(:builtin => 1).first
    return if role.nil?
    role.filters.destroy_all
    role.delete
  end
end
