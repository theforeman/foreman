class ChangeArchitectureNameLimit < ActiveRecord::Migration
  def change
    change_column :architectures, :name, :string, :default => nil, :limit => 255
  end
end
