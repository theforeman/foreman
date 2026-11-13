require Rails.root.join('db/seeds.d/020-permissions_list.rb')

class EnforceUniquePermissions < ActiveRecord::Migration[7.0]
  INDEX_NAME = 'index_permissions_on_name'.freeze

  # Fake models keep the migration independent of future model changes.
  class MigrationPermission < ApplicationRecord
    self.table_name = 'permissions'
  end

  class MigrationFiltering < ApplicationRecord
    self.table_name = 'filterings'
  end

  class MigrationFilter < ApplicationRecord
    self.table_name = 'filters'
  end

  def up
    merge_duplicates
    add_index :permissions, :name, :unique => true, :name => INDEX_NAME
  end

  def down
    remove_index :permissions, :name => INDEX_NAME
  end

  private

  def merge_duplicates
    affected_filter_ids = []

    MigrationPermission.group(:name).having('COUNT(*) > 1').pluck(:name).each do |name|
      permissions = MigrationPermission.where(:name => name).order(:id).to_a
      original_resource_types = permissions.map(&:resource_type).uniq
      retained_types = permissions.index_by(&:id).transform_values(&:resource_type)
      retained = retained_permission(permissions, name)
      duplicates = permissions.reject { |permission| permission.id == retained.id }

      if original_resource_types.size > 1 || retained_types[retained.id] != retained.resource_type
        affected_filter_ids.concat(MigrationFiltering.where(:permission_id => permissions.map(&:id)).pluck(:filter_id))
      end

      merge_filterings(duplicates.map(&:id), retained.id)
      MigrationPermission.where(:id => duplicates.map(&:id)).delete_all
    end

    affected_filter_ids.uniq.each { |filter_id| split_mixed_filter(filter_id) }
  end

  def retained_permission(permissions, name)
    # Row id order cannot identify the correct type when legacy duplicates disagree.
    known, expected_type = canonical_resource_type(name)
    unless known
      resource_types = permissions.map(&:resource_type).uniq
      if resource_types.size > 1
        message = "Permission '#{name}' has conflicting resource types without a canonical definition: " \
          "#{resource_types.inspect}"
        raise ActiveRecord::MigrationError,
          message
      end

      return permissions.first
    end

    permissions.find { |permission| permission.resource_type == expected_type } || begin
      permissions.first.tap { |permission| permission.update_column(:resource_type, expected_type) }
    end
  end

  def canonical_resource_type(name)
    core_types = PermissionsList.permissions.each_with_object({}) do |(resource_type, permission_name), mapping|
      mapping[permission_name.to_s] = resource_type
    end
    return [true, core_types[name.to_s]] if core_types.key?(name.to_s)

    return [false, nil] unless defined?(Foreman::Plugin)

    plugin_permissions = Foreman::Plugin.all.flat_map(&:registered_permissions)
    matches = plugin_permissions.select { |permission_name, _options| permission_name.to_s == name.to_s }
    return [false, nil] if matches.empty?

    resource_types = matches.map { |_permission_name, options| options[:resource_type] }.uniq
    if resource_types.size > 1
      raise ActiveRecord::MigrationError,
        "Conflicting registered resource types for permission '#{name}': #{resource_types.inspect}"
    end

    [true, resource_types.first]
  end

  def split_mixed_filter(filter_id)
    filter = MigrationFilter.find_by(:id => filter_id)
    return unless filter

    groups = filtering_rows(filter_id).group_by { |row| row.last }
    return if groups.empty?

    if groups.size == 1
      filter.update_column(:taxonomy_search, taxonomy_search_for(filter.role_id, groups.keys.first))
      return
    end

    retained_type = groups.keys.min_by do |resource_type|
      [-groups.fetch(resource_type).size, resource_type.nil? ? 0 : 1, resource_type.to_s]
    end
    filter.update_column(:taxonomy_search, taxonomy_search_for(filter.role_id, retained_type))

    groups.each do |resource_type, rows|
      next if resource_type == retained_type

      destination = find_or_create_filter(filter, resource_type)
      move_filterings(rows, destination)
    end
  end

  def filtering_rows(filter_id)
    MigrationFiltering
      .joins('INNER JOIN permissions ON permissions.id = filterings.permission_id')
      .where(:filter_id => filter_id)
      .order('filterings.id')
      .pluck('filterings.id', 'filterings.permission_id', 'permissions.resource_type')
  end

  def find_or_create_filter(source, resource_type)
    taxonomy_search = taxonomy_search_for(source.role_id, resource_type)
    candidates = MigrationFilter.where(
      :role_id => source.role_id,
      :search => source.search
    ).where.not(:id => source.id).order(:id)

    candidates.each do |candidate|
      next unless resource_types(candidate.id) == [resource_type]

      candidate.update_column(:taxonomy_search, taxonomy_search) unless candidate.taxonomy_search == taxonomy_search
      return candidate
    end

    MigrationFilter.create!(
      :role_id => source.role_id,
      :search => source.search,
      :taxonomy_search => taxonomy_search
    )
  end

  def taxonomy_search_for(role_id, resource_type)
    filter = Filter.new
    filter.role = Role.find(role_id)
    filter.resource_type = resource_type
    filter.enforce_inherited_taxonomies
    filter.taxonomy_search
  end

  def resource_types(filter_id)
    filtering_rows(filter_id).map(&:last).uniq
  end

  def move_filterings(rows, destination)
    rows.each do |filtering_id, permission_id, _resource_type|
      duplicate = MigrationFiltering.exists?(
        :filter_id => destination.id,
        :permission_id => permission_id
      )

      if duplicate
        MigrationFiltering.where(:id => filtering_id).delete_all
      else
        MigrationFiltering.where(:id => filtering_id).update_all(:filter_id => destination.id)
      end
    end
  end

  def merge_filterings(permission_ids, retained_id)
    MigrationFiltering.where(:permission_id => permission_ids).find_each do |filtering|
      if MigrationFiltering.where(:filter_id => filtering.filter_id, :permission_id => retained_id).exists?
        filtering.delete
      else
        filtering.update_column(:permission_id, retained_id)
      end
    end
  end
end
