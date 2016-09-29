class RemoveArchitectureDefault < ActiveRecord::Migration
  def up
    change_column :architectures, :name, :string, :default => nil
  end

  def down
    change_column :architectures, :name, :string, :default => 'x86_64'
  end
end
