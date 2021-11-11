class AddLookupValueMatchToHostAndHostgroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :lookup_value_matcher, :string, :limit => 255
    add_column :hostgroups, :lookup_value_matcher, :string, :limit => 255
  end

  def down
    remove_column :hosts, :lookup_value_matcher
    remove_column :hostgroups, :lookup_value_matcher
  end
end
