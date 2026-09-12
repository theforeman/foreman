class EnforceUniqueTaxonomies < ActiveRecord::Migration[7.0]
  def up
    # Concurrent creates can race past the model-level uniqueness check and
    # insert duplicates. Abort and list them rather than guessing at a merge -
    # raced rows can carry real associations (hosts, children, parameters...).
    duplicate_keys = Taxonomy.unscoped
      .group(:type, :ancestry, Arel.sql('LOWER(name)'))
      .having('count(*) > 1')
      .pluck(:type, :ancestry, Arel.sql('LOWER(name)'))

    if duplicate_keys.any?
      details = duplicate_keys.map do |type, ancestry, lower_name|
        ids = Taxonomy.unscoped
          .where(:type => type, :ancestry => ancestry)
          .where('LOWER(name) = ?', lower_name)
          .order(:id)
          .pluck(:id)
        "  #{type} #{lower_name.inspect} (ancestry=#{ancestry.inspect}) ids=#{ids.join(', ')}"
      end
      raise "Cannot add unique index on taxonomies; duplicate names exist. " \
        "Delete extra rows and re-run:\n#{details.join("\n")}"
    end

    # ancestry is nullable, and a plain UNIQUE index treats every NULL as
    # distinct, so COALESCE it to match the existing Rails-level validation.
    add_index :taxonomies, "type, COALESCE(ancestry, ''), lower(name)", :unique => true,
      :name => 'index_taxonomies_on_type_ancestry_lower_name'
  end

  def down
    remove_index :taxonomies, :name => 'index_taxonomies_on_type_ancestry_lower_name'
  end
end
