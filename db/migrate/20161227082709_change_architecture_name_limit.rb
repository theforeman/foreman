class ChangeArchitectureNameLimit < ActiveRecord::Migration[4.2]
  def change
    change_column :architectures, :name, :string, :default => nil, :limit => 255
  end
end
