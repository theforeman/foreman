class ChangeBuiltinToBooleanInRoles < ActiveRecord::Migration
  def self.up
	change_column :roles, :builtin, 'boolean USING CAST(builtin AS boolean)'
  end

  def self.down
	change_column :roles, :builtin,  'integer USING CAST(builtin AS integer)'
  end
end
