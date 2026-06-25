class MigrateTaxonomiesIgnoreTypesToJsonb < ActiveRecord::Migration[7.0]
  # Fake model to isolate migration from future model changes
  class MigrationTaxonomy < ApplicationRecord
    self.table_name = 'taxonomies'
    self.inheritance_column = :_type_disabled
    serialize :ignore_types_yaml, coder: YAML
  end

  def up
    rename_column :taxonomies, :ignore_types, :ignore_types_yaml
    add_column :taxonomies, :ignore_types, :jsonb, default: []
    migrate_yaml_to_jsonb
    remove_column :taxonomies, :ignore_types_yaml
    add_index :taxonomies, :ignore_types, using: :gin
  end

  def down
    remove_index :taxonomies, :ignore_types
    add_column :taxonomies, :ignore_types_yaml, :text
    migrate_jsonb_to_yaml
    remove_column :taxonomies, :ignore_types
    rename_column :taxonomies, :ignore_types_yaml, :ignore_types
  end

  private

  def migrate_yaml_to_jsonb
    MigrationTaxonomy.reset_column_information
    MigrationTaxonomy.find_each do |taxonomy|
      value = taxonomy.ignore_types_yaml
      unless value.is_a?(Array) || value.nil?
        Rails.logger.warn("MigrateTaxonomiesIgnoreTypesToJsonb: taxonomy #{taxonomy.id} had unexpected ignore_types value #{value.class}, resetting to []")
        value = []
      end
      taxonomy.update_column(:ignore_types, value || [])
    end
  end

  def migrate_jsonb_to_yaml
    MigrationTaxonomy.reset_column_information
    MigrationTaxonomy.find_each do |taxonomy|
      value = taxonomy.ignore_types || []
      taxonomy.update_column(:ignore_types_yaml, value.empty? ? nil : value.to_yaml)
    end
  end
end
