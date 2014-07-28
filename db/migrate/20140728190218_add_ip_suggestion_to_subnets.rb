class AddIpSuggestionToSubnets < ActiveRecord::Migration
  def change
    add_column :subnets, :ipam, :boolean, :default => true
  end
end
