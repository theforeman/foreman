class AddFilterIdToFilters < ActiveRecord::Migration
  def change
    add_column :filters, :filter_id, :int
  end
end
