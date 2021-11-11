class AddTemplateToSubnets < ActiveRecord::Migration[5.1]
  def change
    add_column :subnets, :template_id, :integer
  end
end
