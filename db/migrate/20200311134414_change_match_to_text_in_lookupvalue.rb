class ChangeMatchToTextInLookupvalue < ActiveRecord::Migration[5.2]
  def change
    change_column :lookup_values, :match, :text, :limit => nil
  end
end
