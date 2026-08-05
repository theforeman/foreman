class AddUniqueIndexToHostgroupName < ActiveRecord::Migration[7.0]
  INDEX_NAME = 'index_hostgroups_on_lower_name_and_ancestry'.freeze

  # Fake models to isolate migration from future model changes
  class MigrationHostgroup < ApplicationRecord
    self.table_name = 'hostgroups'
  end

  class MigrationLookupValue < ApplicationRecord
    self.table_name = 'lookup_values'
  end

  DUPLICATES_SQL = <<~SQL.freeze
    SELECT string_agg(id::text, ',' ORDER BY id)
      FROM hostgroups
     GROUP BY LOWER(name), COALESCE(ancestry, '')
    HAVING COUNT(*) > 1
  SQL

  def up
    rebuild_titles if rename_duplicates.positive?

    # LOWER() mirrors the model's :case_sensitive => false uniqueness validation.
    # COALESCE() is required because root host groups have ancestry NULL and
    # PostgreSQL considers NULLs distinct in a unique index - a plain
    # (name, ancestry) index would not constrain top level groups at all.
    add_index :hostgroups, "LOWER(name), COALESCE(ancestry, '')", unique: true, name: INDEX_NAME
  end

  def down
    remove_index :hostgroups, name: INDEX_NAME
  end

  private

  # Duplicates can exist despite the model validation: it is bypassed by
  # update_all/update_column/save(:validate => false) and by concurrent
  # creates.
  def rename_duplicates
    renamed = 0
    connection.select_values(DUPLICATES_SQL).each do |ids|
      # keep the oldest record of each group, rename the rest
      ids.split(',').drop(1).each do |id|
        rename(MigrationHostgroup.find(id))
        renamed += 1
      end
    end

    renamed
  end

  def rename(hostgroup)
    new_name = free_name_for(hostgroup)
    say "Host group #{hostgroup.title.inspect} (id #{hostgroup.id}) duplicates a sibling name, renaming to #{new_name.inspect}"
    hostgroup.update_column(:name, new_name)
  end

  def free_name_for(hostgroup)
    base = "#{hostgroup.name}-#{hostgroup.id}"[0, 255]
    candidate = base
    suffix = 0
    while taken?(candidate, hostgroup)
      suffix += 1
      candidate = "#{base[0, 250]}-#{suffix}"
    end

    candidate
  end

  def taken?(candidate, hostgroup)
    MigrationHostgroup.where(ancestry: hostgroup.ancestry) # nil becomes IS NULL, same grouping as the index
                      .where.not(id: hostgroup.id)
                      .where('LOWER(name) = LOWER(?)', candidate)
                      .exists?
  end

  # hostgroups.title is denormalized ("parent/child"), so a rename invalidates
  # the title of the renamed group and of all its descendants. LookupValue
  # matchers embed the title as well ("hostgroup=parent/child").
  def rebuild_titles
    rows = MigrationHostgroup.pluck(:id, :name, :ancestry, :title)
    names = rows.to_h { |id, name, _ancestry, _title| [id, name] }

    rows.each do |id, name, ancestry, title|
      path = ancestry.to_s.split('/').map { |parent_id| names[parent_id.to_i] }
      new_title = (path + [name]).compact.join('/')
      next if new_title == title

      MigrationHostgroup.where(id: id).update_all(title: new_title)
      MigrationLookupValue.where(match: "hostgroup=#{title}").update_all(match: "hostgroup=#{new_title}")
    end
  end
end
