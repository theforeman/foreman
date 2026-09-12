class EnforceUniqueTaxonomies < ActiveRecord::Migration[7.0]
  INDEX_NAME = 'index_taxonomies_on_type_ancestry_lower_name'.freeze

  # Fake model to isolate migration from future model changes
  class MigrationTaxonomy < ApplicationRecord
    self.table_name = 'taxonomies'
    self.inheritance_column = :_type_disabled
  end

  class MigrationLookupValue < ApplicationRecord
    self.table_name = 'lookup_values'
  end

  DUPLICATES_SQL = <<~SQL.freeze
    SELECT string_agg(id::text, ',' ORDER BY id)
      FROM taxonomies
     GROUP BY type, LOWER(name), COALESCE(ancestry, '')
    HAVING COUNT(*) > 1
  SQL

  def up
    rebuild_titles if rename_duplicates.positive?

    add_index :taxonomies, "type, COALESCE(ancestry, ''), lower(name)",
      :unique => true, :name => INDEX_NAME
  end

  def down
    remove_index :taxonomies, :name => INDEX_NAME
  end

  private

  def rename_duplicates
    renamed = 0
    connection.select_values(DUPLICATES_SQL).each do |ids|
      ids.split(',').drop(1).each do |id|
        rename(MigrationTaxonomy.find(id))
        renamed += 1
      end
    end

    renamed
  end

  def rename(taxonomy)
    new_name = free_name_for(taxonomy)
    say "#{taxonomy.type} #{taxonomy.title.inspect} (id #{taxonomy.id}) duplicates a sibling name, renaming to #{new_name.inspect}"
    taxonomy.update_column(:name, new_name)
  end

  def free_name_for(taxonomy)
    base = "#{taxonomy.name}-#{taxonomy.id}"[0, 255]
    candidate = base
    suffix = 0
    while taken?(candidate, taxonomy)
      suffix += 1
      candidate = "#{base[0, 250]}-#{suffix}"
    end

    candidate
  end

  def taken?(candidate, taxonomy)
    MigrationTaxonomy.where(:type => taxonomy.type, :ancestry => taxonomy.ancestry)
                      .where.not(:id => taxonomy.id)
                      .where('LOWER(name) = LOWER(?)', candidate)
                      .exists?
  end

  def rebuild_titles
    rows = MigrationTaxonomy.pluck(:id, :type, :name, :ancestry, :title)
    names = rows.to_h { |id, _type, name, _ancestry, _title| [id, name] }

    rows.each do |id, type, name, ancestry, title|
      path = ancestry.to_s.split('/').map { |parent_id| names[parent_id.to_i] }
      new_title = (path + [name]).compact.join('/')
      next if new_title == title

      MigrationTaxonomy.where(:id => id).update_all(:title => new_title)
      next unless type.present?

      matcher_prefix = "#{type.downcase}="
      MigrationLookupValue.where(:match => "#{matcher_prefix}#{title}")
        .update_all(:match => "#{matcher_prefix}#{new_title}")
    end
  end
end
