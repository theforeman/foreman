class AddIpSuggestionToSubnets < ActiveRecord::Migration[4.2]
  def change
    add_column :subnets, :ipam, :boolean, :default => true
  end
end
