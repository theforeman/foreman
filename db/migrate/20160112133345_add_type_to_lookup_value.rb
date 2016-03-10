class AddTypeToLookupValue < ActiveRecord::Migration
  def change
    add_column :lookup_values, :type, :string
    LookupValue.reset_column_information
    LookupValue.all.each do |lookup_value|
      subclass = lookup_value.lookup_key.puppet? ?  'PuppetLookupValue' : 'LookupValue'
      lookup_value.type = subclass
      lookup_value.save
    end
  end
end
