require 'test_helper'
require Rails.root.join('db/migrate/20260805084100_add_unique_index_to_hostgroup_name.rb')

class AddUniqueIndexToHostgroupNameTest < ActiveSupport::TestCase
  INDEX_NAME = AddUniqueIndexToHostgroupName::INDEX_NAME

  # Plain AR access to the tables, so that the tests can both create the invalid
  # data the migration is supposed to clean up and read the result back without
  # the model validations, the title callbacks or the default scope interfering.
  HostgroupRecord = AddUniqueIndexToHostgroupName::MigrationHostgroup
  LookupValueRecord = AddUniqueIndexToHostgroupName::MigrationLookupValue

  let(:migration) { AddUniqueIndexToHostgroupName.new }

  setup do
    # Start from the pre-migration state even when the test database was built
    # from a schema that already contains the index.
    migrate_down if index_exists?
  end

  context 'up' do
    test 'adds the unique index' do
      assert_not index_exists?

      migrate_up

      assert index_exists?
    end

    test 'rejects duplicate sibling names once the index is in place' do
      parent = FactoryBot.create(:hostgroup, name: 'ancestor')
      FactoryBot.create(:hostgroup, name: 'child', parent: parent)
      migrate_up

      assert_rejected_by_index do
        HostgroupRecord.create!(name: 'child', ancestry: parent.id.to_s)
      end
    end

    test 'rejects duplicate names differing only in case' do
      FactoryBot.create(:hostgroup, name: 'webservers')
      migrate_up

      assert_rejected_by_index { HostgroupRecord.create!(name: 'WebServers') }
    end

    # Root host groups have ancestry NULL and PostgreSQL treats NULLs as
    # distinct, so this is what the COALESCE in the index is there for.
    test 'rejects duplicate names of root host groups' do
      FactoryBot.create(:hostgroup, name: 'toplevel')
      migrate_up

      assert_rejected_by_index { HostgroupRecord.create!(name: 'toplevel', ancestry: nil) }
    end

    test 'allows the same name under different parents' do
      first = FactoryBot.create(:hostgroup, name: 'first-parent')
      second = FactoryBot.create(:hostgroup, name: 'second-parent')
      FactoryBot.create(:hostgroup, name: 'shared', parent: first)
      migrate_up

      assert HostgroupRecord.create!(name: 'shared', ancestry: second.id.to_s).persisted?
      assert HostgroupRecord.create!(name: 'shared', ancestry: nil).persisted?
    end

    test 'leaves host groups untouched when there are no duplicates' do
      FactoryBot.create(:hostgroup, :with_parent)
      before = HostgroupRecord.order(:id).pluck(:id, :name, :title)

      migrate_up

      assert_equal before, HostgroupRecord.order(:id).pluck(:id, :name, :title)
    end
  end

  context 'renaming pre-existing duplicates' do
    test 'keeps the oldest duplicate and renames the newer one' do
      original = FactoryBot.create(:hostgroup, name: 'dupe')
      duplicate = create_duplicate_of(original)

      migrate_up

      assert_equal 'dupe', reload(original).name
      assert_equal "dupe-#{duplicate.id}", reload(duplicate).name
    end

    test 'renames every duplicate but the oldest' do
      original = FactoryBot.create(:hostgroup, name: 'dupe')
      second = create_duplicate_of(original)
      third = create_duplicate_of(original)

      migrate_up

      assert_equal 'dupe', reload(original).name
      assert_equal "dupe-#{second.id}", reload(second).name
      assert_equal "dupe-#{third.id}", reload(third).name
    end

    test 'renames duplicates differing only in case' do
      original = FactoryBot.create(:hostgroup, name: 'dupe')
      duplicate = create_duplicate_of(original, name: 'DUPE')

      migrate_up

      assert_equal 'dupe', reload(original).name
      assert_equal "DUPE-#{duplicate.id}", reload(duplicate).name
    end

    test 'renames duplicated children of the same parent' do
      parent = FactoryBot.create(:hostgroup, name: 'ancestor')
      original = FactoryBot.create(:hostgroup, name: 'child', parent: parent)
      duplicate = create_duplicate_of(original, parent: parent)

      migrate_up

      assert_equal 'child', reload(original).name
      assert_equal "child-#{duplicate.id}", reload(duplicate).name
    end

    test 'picks a free name when the generated one is already taken' do
      original = FactoryBot.create(:hostgroup, name: 'app')
      duplicate = FactoryBot.create(:hostgroup, name: 'placeholder')
      FactoryBot.create(:hostgroup, name: "app-#{duplicate.id}")
      duplicate.update_column(:name, original.name)

      migrate_up

      assert_equal "app-#{duplicate.id}-1", reload(duplicate).name
    end

    # The rows are inserted straight into the table, a name this long does not
    # fit into the lookup_value_matcher the model would derive from it.
    test 'keeps the generated name within the column limit' do
      long_name = 'a' * 255
      original = HostgroupRecord.create!(name: long_name, title: long_name)
      duplicate = HostgroupRecord.create!(name: long_name, title: long_name)

      migrate_up

      new_name = reload(duplicate).name
      assert_equal long_name, reload(original).name
      assert_operator new_name.length, :<=, 255
      assert_not_equal long_name, new_name
    end

    test 'adds the index after the duplicates are resolved' do
      original = FactoryBot.create(:hostgroup, name: 'dupe')
      create_duplicate_of(original)

      migrate_up

      assert index_exists?
    end
  end

  context 'rebuilding denormalized titles' do
    test 'rebuilds the title of the renamed host group' do
      original = FactoryBot.create(:hostgroup, name: 'group')
      duplicate = create_duplicate_of(original)

      migrate_up

      assert_equal "group-#{duplicate.id}", reload(duplicate).title
    end

    test 'rebuilds the titles of the descendants of the renamed host group' do
      original = FactoryBot.create(:hostgroup, name: 'group')
      duplicate = FactoryBot.create(:hostgroup, name: 'placeholder')
      child = FactoryBot.create(:hostgroup, name: 'child', parent: duplicate)
      grandchild = FactoryBot.create(:hostgroup, name: 'grandchild', parent: child)
      duplicate.update_column(:name, original.name)

      migrate_up

      renamed = "group-#{duplicate.id}"
      assert_equal renamed, reload(duplicate).title
      assert_equal "#{renamed}/child", reload(child).title
      assert_equal "#{renamed}/child/grandchild", reload(grandchild).title
    end

    test 'keeps the titles of unrelated host groups' do
      unrelated = FactoryBot.create(:hostgroup, :with_parent, name: 'unrelated')
      original = FactoryBot.create(:hostgroup, name: 'group')
      create_duplicate_of(original)

      migrate_up

      assert_equal unrelated.title, reload(unrelated).title
    end

    test 'moves the lookup value matchers to the new title' do
      original = FactoryBot.create(:hostgroup, name: 'group')
      duplicate = FactoryBot.create(:hostgroup, name: 'placeholder')
      matcher = create_matcher_for(duplicate)
      duplicate.update_column(:name, original.name)

      migrate_up

      assert_equal "hostgroup=group-#{duplicate.id}", matcher.reload.match
    end

    test 'moves the lookup value matchers of the descendants as well' do
      original = FactoryBot.create(:hostgroup, name: 'group')
      duplicate = FactoryBot.create(:hostgroup, name: 'placeholder')
      child = FactoryBot.create(:hostgroup, name: 'child', parent: duplicate)
      matcher = create_matcher_for(child)
      duplicate.update_column(:name, original.name)

      migrate_up

      assert_equal "hostgroup=group-#{duplicate.id}/child", matcher.reload.match
    end

    test 'keeps the lookup value matchers of unrelated host groups' do
      unrelated = FactoryBot.create(:hostgroup, name: 'unrelated')
      matcher = create_matcher_for(unrelated)
      original = FactoryBot.create(:hostgroup, name: 'group')
      create_duplicate_of(original)

      migrate_up

      assert_equal 'hostgroup=unrelated', matcher.reload.match
    end
  end

  context 'down' do
    test 'removes the index' do
      migrate_up
      assert index_exists?

      migrate_down

      assert_not index_exists?
    end

    test 'allows duplicates again' do
      FactoryBot.create(:hostgroup, name: 'toplevel')
      migrate_up
      migrate_down

      assert HostgroupRecord.create!(name: 'toplevel').persisted?
    end

    test 'does not rename anything back' do
      original = FactoryBot.create(:hostgroup, name: 'dupe')
      duplicate = create_duplicate_of(original)
      migrate_up

      migrate_down

      assert_equal "dupe-#{duplicate.id}", reload(duplicate).name
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
    ActiveRecord::Base.connection.index_name_exists?(:hostgroups, INDEX_NAME)
  end

  # A duplicate cannot be created through the model, its uniqueness validation
  # is exactly what the migration assumes was bypassed.
  def create_duplicate_of(hostgroup, name: nil, parent: nil)
    duplicate = FactoryBot.create(:hostgroup, parent: parent)
    duplicate.update_column(:name, name || hostgroup.name)
    duplicate
  end

  def create_matcher_for(hostgroup)
    LookupValueRecord.create!(match: "hostgroup=#{hostgroup.title}", value: 'whatever')
  end

  def reload(hostgroup)
    HostgroupRecord.find(hostgroup.id)
  end

  def assert_rejected_by_index(&insert)
    assert_raises(ActiveRecord::RecordNotUnique) do
      # The savepoint keeps the rejected insert from aborting the surrounding
      # test transaction.
      HostgroupRecord.transaction(requires_new: true, &insert)
    end
  end
end
