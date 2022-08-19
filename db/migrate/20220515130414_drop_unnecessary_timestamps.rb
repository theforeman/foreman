class DropUnnecessaryTimestamps < ActiveRecord::Migration[6.0]
  def up
    if ActiveRecord::Base.connection.column_exists?(:taxable_taxonomies, :created_at)
      remove_column :taxable_taxonomies, :created_at, :datetime
    end

    if ActiveRecord::Base.connection.column_exists?(:taxable_taxonomies, :updated_at)
      remove_column :taxable_taxonomies, :updated_at, :datetime
    end
  end

  def down
    unless ActiveRecord::Base.connection.column_exists?(:taxable_taxonomies, :created_at)
      add_column :taxable_taxonomies, :created_at, :datetime
    end

    unless ActiveRecord::Base.connection.column_exists?(:taxable_taxonomies, :updated_at)
      add_column :taxable_taxonomies, :updated_at, :datetime
    end
  end
end
