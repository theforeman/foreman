class AddDomainToParameter < ActiveRecord::Migration
  def up
    add_column :parameters, :domain_id, :integer
  end

  def down
    remove_column :parameters, :domain_id
  end
end
