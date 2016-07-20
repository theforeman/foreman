class RemoveArchitectureDefault < ActiveRecord::Migration[4.2]
  def up
    change_column :architectures, :name, :string, :default => nil
  end

  def down
    change_column :architectures, :name, :string, :default => 'x86_64'
  end
end
