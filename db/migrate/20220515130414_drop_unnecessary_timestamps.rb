class DropUnnecessaryTimestamps < ActiveRecord::Migration[6.0]
  def change
    [
      :taxable_taxonomies,
      :taxonomies,
    ].each do |table|
      remove_column table, :created_at, :datetime
      remove_column table, :updated_at, :datetime
    end
  end
end
