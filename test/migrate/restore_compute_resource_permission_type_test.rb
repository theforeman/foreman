require 'test_helper'
require Rails.root.join('db/migrate/20261113090000_restore_compute_resource_permission_type.rb')

class RestoreComputeResourcePermissionTypeTest < ActiveSupport::TestCase
  MigrationFilter = RestoreComputeResourcePermissionType::MigrationFilter
  MigrationFiltering = RestoreComputeResourcePermissionType::MigrationFiltering

  let(:migration) { RestoreComputeResourcePermissionType.new }

  test 'restores the resource type and separates mixed filters' do
    view_permission = Permission.find_by!(:name => 'view_compute_resources')
    view_permission.update_column(:resource_type, nil)
    organization = FactoryBot.create(:organization)
    miscellaneous_permission = FactoryBot.create(
      :permission,
      :name => 'migration_miscellaneous_permission',
      :resource_type => nil
    )
    compute_permission = FactoryBot.create(
      :permission,
      :name => 'migration_compute_resource_permission',
      :resource_type => 'ComputeResource'
    )
    role = FactoryBot.create(:role, :organizations => [organization])
    miscellaneous_filter = FactoryBot.create(
      :filter,
      :role => role,
      :permissions => [miscellaneous_permission]
    )
    compute_filter = FactoryBot.create(
      :filter,
      :role => role,
      :permissions => [compute_permission]
    )
    Filtering.create!(:filter => miscellaneous_filter, :permission => view_permission)
    Filtering.create!(:filter => compute_filter, :permission => view_permission)

    migration.up

    assert_equal 'ComputeResource', view_permission.reload.resource_type
    assert_equal [miscellaneous_permission.id],
      MigrationFiltering.where(:filter_id => miscellaneous_filter.id).pluck(:permission_id)
    assert_equal [compute_permission.id, view_permission.id].sort,
      MigrationFiltering.where(:filter_id => compute_filter.id).pluck(:permission_id).sort
    assert_equal [nil], permission_resource_types(miscellaneous_filter.id)
    assert_equal ['ComputeResource'], permission_resource_types(compute_filter.id)
    assert_equal "(organization_id ^ (#{organization.id}))", compute_filter.reload.taxonomy_search
  end

  test 'rebuilds taxonomy search for a homogeneous miscellaneous filter' do
    view_permission = Permission.find_by!(:name => 'view_compute_resources')
    view_permission.update_column(:resource_type, nil)
    organization = FactoryBot.create(:organization)
    role = FactoryBot.create(:role, :organizations => [organization])
    filter = MigrationFilter.create!(:role_id => role.id, :search => nil, :taxonomy_search => nil)
    MigrationFiltering.create!(:filter_id => filter.id, :permission_id => view_permission.id)

    migration.up

    assert_equal 'ComputeResource', view_permission.reload.resource_type
    assert_equal "(organization_id ^ (#{organization.id}))", MigrationFilter.find(filter.id).taxonomy_search
  end

  private

  def permission_resource_types(filter_id)
    MigrationFiltering
      .joins('INNER JOIN permissions ON permissions.id = filterings.permission_id')
      .where(:filter_id => filter_id)
      .distinct
      .pluck('permissions.resource_type')
  end
end
