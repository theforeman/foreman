class AddDomainToParameter < ActiveRecord::Migration
  def self.up
    add_column :parameters, :domain_id, :integer

  end

  def self.down
    remove_column :parameters, :domain_id
  end
end
