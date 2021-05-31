class AddUniqueIndexToLookupValue < ActiveRecord::Migration[6.0]
  def up
    LookupValue.where.not(id: LookupValue.group(:lookup_key_id, :match).select('MAX(id)')).each do |lookup_value|
      say "Deleting duplicate override value for #{lookup_value.lookup_key.class.humanize_class_name} #{lookup_value.lookup_key.key} with matcher #{lookup_value.match} and value #{lookup_value.value}"
      lookup_value.destroy
    end
    add_index :lookup_values, [:lookup_key_id, :match], unique: true
  end

  def down
    remove_index :lookup_values, column: [:lookup_key_id, :match], unique: true
  end
end
