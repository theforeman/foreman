class RemoveSpacesFromSmartVariableKey < ActiveRecord::Migration[4.2]
  def up
    variable_lookup_keys = VariableLookupKey.arel_table
    VariableLookupKey.where(variable_lookup_keys[:key].matches("% %")).each do |lookup_key|
      lookup_key.update_attribute(:key, lookup_key.key.tr(' ', '_'))
    end
  end
end
