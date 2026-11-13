class RestoreComputeResourcePermissionType < ActiveRecord::Migration[7.0]
  # The core permission seed declares this permission as a ComputeResource.
  PERMISSION_NAME = 'view_compute_resources'.freeze
  RESOURCE_TYPE = 'ComputeResource'.freeze

  class MigrationPermission < ApplicationRecord
    self.table_name = 'permissions'
  end

  class MigrationFilter < ApplicationRecord
    self.table_name = 'filters'
  end

  class MigrationFiltering < ApplicationRecord
    self.table_name = 'filterings'
  end

  def up
    permission = MigrationPermission.find_by(:name => PERMISSION_NAME)
    return unless permission

    permission.update_column(:resource_type, RESOURCE_TYPE) unless permission.resource_type == RESOURCE_TYPE

    MigrationFiltering.where(:permission_id => permission.id).distinct.pluck(:filter_id).each do |filter_id|
      split_mixed_filter(filter_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot restore the previous permission resource type safely'
  end

  private

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
end
