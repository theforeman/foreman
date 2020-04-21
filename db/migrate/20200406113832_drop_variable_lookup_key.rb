class DropVariableLookupKey < ActiveRecord::Migration[5.2]
  def change
    variables = LookupKey.where(:type => 'VariableLookupKey')
    LookupValue.where(lookup_key: variables).delete_all
    variables.delete_all
  end
end
