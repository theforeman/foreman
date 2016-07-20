class RenameAnonymousRole < ActiveRecord::Migration[4.2]
  def up
    role = Role.where(:name => 'Anonymous').first
    role.update_column(:name, 'Default role') if role.present?
  end

  def down
    role = Role.where(:name => 'Default role').first
    role.update_column(:name, 'Anonymous') if role.present?
  end
end
