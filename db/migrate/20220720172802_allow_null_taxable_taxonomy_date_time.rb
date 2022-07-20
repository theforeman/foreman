class AllowNullTaxableTaxonomyDateTime < ActiveRecord::Migration[6.1]
  def change
    if column_exists? :taxable_taxonomies, :created_at
      change_column_null :taxable_taxonomies, :created_at, true
    else
      add_column :taxable_taxonomies, :created_at, :datetime, :null => true
    end

    if column_exists? :taxable_taxonomies, :updated_at
      change_column_null :taxable_taxonomies, :updated_at, true
    else
      add_column :taxable_taxonomies, :updated_at, :datetime, :null => true
    end
  end
end
