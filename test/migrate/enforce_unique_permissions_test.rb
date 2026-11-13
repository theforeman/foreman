require 'test_helper'
require Rails.root.join('db/migrate/20260922090000_enforce_unique_permissions.rb')

class EnforceUniquePermissionsTest < ActiveSupport::TestCase
  INDEX_NAME = EnforceUniquePermissions::INDEX_NAME

  PermissionRecord = EnforceUniquePermissions::MigrationPermission
  FilteringRecord = EnforceUniquePermissions::MigrationFiltering

  let(:migration) { EnforceUniquePermissions.new }

  setup do
    migrate_down if index_exists?
  end

  context 'up' do
    test 'adds the unique index' do
      migrate_up

      assert index_exists?
    end

    test 'rejects duplicate permission names once the index is in place' do
      PermissionRecord.create!(:name => 'view_unique_index_test', :resource_type => 'Host')
      migrate_up

      assert_rejected_by_index do
        PermissionRecord.create!(:name => 'view_unique_index_test', :resource_type => 'Host')
      end
    end

    test 'keeps the oldest permission and removes its duplicates' do
      retained = PermissionRecord.create!(:name => 'view_duplicate_test', :resource_type => 'Host')
      duplicate = PermissionRecord.create!(:name => retained.name, :resource_type => retained.resource_type)

      migrate_up

      assert PermissionRecord.exists?(retained.id)
      assert_not PermissionRecord.exists?(duplicate.id)
      assert_equal 1, PermissionRecord.where(:name => retained.name).count
    end

    test 'keeps the canonical resource type and separates mixed filters' do
      incorrect = PermissionRecord.find_by!(:name => 'view_compute_resources')
      incorrect.update_column(:resource_type, nil)
      canonical = PermissionRecord.create!(:name => incorrect.name, :resource_type => 'ComputeResource')
      organization = FactoryBot.create(:organization)
      role = FactoryBot.create(:role, :organizations => [organization])
      miscellaneous_permission = Permission.find_by!(:name => 'access_dashboard')
      compute_permission = Permission.find_by!(:name => 'create_compute_resources')
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
      FilteringRecord.create!(:filter_id => miscellaneous_filter.id, :permission_id => canonical.id)
      FilteringRecord.create!(:filter_id => compute_filter.id, :permission_id => incorrect.id)

      migrate_up

      assert PermissionRecord.exists?(canonical.id)
      assert_not PermissionRecord.exists?(incorrect.id)
      assert_equal 'ComputeResource', PermissionRecord.find(canonical.id).resource_type
      assert_equal [miscellaneous_permission.id],
        FilteringRecord.where(:filter_id => miscellaneous_filter.id).pluck(:permission_id)
      assert_equal [canonical.id, compute_permission.id].sort,
        FilteringRecord.where(:filter_id => compute_filter.id).pluck(:permission_id).sort
      assert_equal [nil], miscellaneous_filter.reload.permissions.pluck(:resource_type).uniq
      assert_equal ['ComputeResource'], compute_filter.reload.permissions.pluck(:resource_type).uniq
      assert_equal "(organization_id ^ (#{organization.id}))", compute_filter.reload.taxonomy_search
    end

    test 'raises when conflicting permission types have no canonical definition' do
      permission = PermissionRecord.create!(
        :name => 'migration_unknown_conflict_test',
        :resource_type => nil
      )
      PermissionRecord.create!(:name => permission.name, :resource_type => 'Host')

      error = assert_raises(ActiveRecord::MigrationError) { migrate_up }

      assert_includes error.message, permission.name
    end

    test 'moves filtering associations to the retained permission' do
      retained = PermissionRecord.create!(:name => 'view_moved_filtering_test', :resource_type => 'Host')
      duplicate = PermissionRecord.create!(:name => retained.name, :resource_type => retained.resource_type)
      filter = FactoryBot.create(:filter)
      filtering = FilteringRecord.create!(:filter_id => filter.id, :permission_id => duplicate.id)

      migrate_up

      assert_equal retained.id, filtering.reload.permission_id
    end

    test 'removes duplicate filtering associations' do
      retained = PermissionRecord.create!(:name => 'view_duplicate_filtering_test', :resource_type => 'Host')
      duplicate = PermissionRecord.create!(:name => retained.name, :resource_type => retained.resource_type)
      filter = FactoryBot.create(:filter)
      FilteringRecord.create!(:filter_id => filter.id, :permission_id => retained.id)
      FilteringRecord.create!(:filter_id => filter.id, :permission_id => duplicate.id)

      migrate_up

      assert_equal 1, FilteringRecord.where(:filter_id => filter.id, :permission_id => retained.id).count
    end

    test 'preserves associations from multiple duplicate permissions' do
      retained = PermissionRecord.create!(:name => 'view_multiple_duplicates_test', :resource_type => 'Host')
      second = PermissionRecord.create!(:name => retained.name, :resource_type => retained.resource_type)
      third = PermissionRecord.create!(:name => retained.name, :resource_type => retained.resource_type)
      first_filter = FactoryBot.create(:filter)
      second_filter = FactoryBot.create(:filter)
      FilteringRecord.create!(:filter_id => first_filter.id, :permission_id => second.id)
      FilteringRecord.create!(:filter_id => second_filter.id, :permission_id => third.id)

      migrate_up

      assert_equal [first_filter.id, second_filter.id].sort,
        FilteringRecord.where(:permission_id => retained.id).pluck(:filter_id).sort
    end

    test 'leaves unique permissions and their associations unchanged' do
      permission = PermissionRecord.create!(:name => 'view_unchanged_test', :resource_type => 'Host')
      filter = FactoryBot.create(:filter)
      filtering = FilteringRecord.create!(:filter_id => filter.id, :permission_id => permission.id)

      migrate_up

      assert_equal permission.id, filtering.reload.permission_id
      assert PermissionRecord.exists?(permission.id)
    end
  end

  context 'down' do
    test 'removes the unique index' do
      migrate_up
      migrate_down

      assert_not index_exists?
    end

    test 'allows duplicate names again' do
      PermissionRecord.create!(:name => 'view_after_rollback_test', :resource_type => 'Host')
      migrate_up
      migrate_down

      assert PermissionRecord.create!(:name => 'view_after_rollback_test', :resource_type => 'Host').persisted?
    end
  end

  private

  def migrate_up
    migration.suppress_messages { migration.up }
  end

  def migrate_down
    migration.suppress_messages { migration.down }
  end

  def index_exists?
    ActiveRecord::Base.connection.index_name_exists?(:permissions, INDEX_NAME)
  end

  def assert_rejected_by_index(&insert)
    assert_raises(ActiveRecord::RecordNotUnique) do
      PermissionRecord.transaction(:requires_new => true, &insert)
    end
  end
end
