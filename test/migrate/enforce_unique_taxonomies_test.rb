require 'test_helper'
require Rails.root.join('db/migrate/20260814125426_enforce_unique_taxonomies.rb')

class EnforceUniqueTaxonomiesTest < ActiveSupport::TestCase
  INDEX_NAME = EnforceUniqueTaxonomies::INDEX_NAME

  TaxonomyRecord = EnforceUniqueTaxonomies::MigrationTaxonomy
  LookupValueRecord = EnforceUniqueTaxonomies::MigrationLookupValue

  let(:migration) { EnforceUniqueTaxonomies.new }

  setup do
    migrate_down if index_exists?
  end

  context 'up' do
    test 'adds the unique index' do
      assert_not index_exists?

      migrate_up

      assert index_exists?
    end

    test 'rejects duplicate sibling location names once the index is in place' do
      parent = FactoryBot.create(:location, :name => 'ancestor')
      FactoryBot.create(:location, :name => 'child', :parent => parent)
      migrate_up

      assert_rejected_by_index do
        TaxonomyRecord.create!(:type => 'Location', :name => 'child', :ancestry => parent.id.to_s)
      end
    end

    test 'rejects duplicate location names differing only in case' do
      FactoryBot.create(:location, :name => 'datacenter')
      migrate_up

      assert_rejected_by_index { TaxonomyRecord.create!(:type => 'Location', :name => 'DataCenter') }
    end

    test 'rejects duplicate names of root locations' do
      FactoryBot.create(:location, :name => 'toplevel')
      migrate_up

      assert_rejected_by_index { TaxonomyRecord.create!(:type => 'Location', :name => 'toplevel', :ancestry => nil) }
    end

    test 'allows the same location name under different parents' do
      first = FactoryBot.create(:location, :name => 'first-parent')
      second = FactoryBot.create(:location, :name => 'second-parent')
      FactoryBot.create(:location, :name => 'shared', :parent => first)
      migrate_up

      assert TaxonomyRecord.create!(:type => 'Location', :name => 'shared', :ancestry => second.id.to_s).persisted?
      assert TaxonomyRecord.create!(:type => 'Location', :name => 'shared', :ancestry => nil).persisted?
    end

    test 'allows the same name for a location and an organization' do
      FactoryBot.create(:location, :name => 'shared')
      migrate_up

      assert TaxonomyRecord.create!(:type => 'Organization', :name => 'shared').persisted?
    end

    test 'leaves locations untouched when there are no duplicates' do
      FactoryBot.create(:location, :with_parent)
      before = TaxonomyRecord.where(:type => 'Location').order(:id).pluck(:id, :name, :title)

      migrate_up

      assert_equal before, TaxonomyRecord.where(:type => 'Location').order(:id).pluck(:id, :name, :title)
    end
  end

  context 'renaming pre-existing duplicates' do
    test 'keeps the oldest duplicate and renames the newer one' do
      original = FactoryBot.create(:location, :name => 'dupe')
      duplicate = create_duplicate_of(original)

      migrate_up

      assert_equal 'dupe', reload(original).name
      assert_equal "dupe-#{duplicate.id}", reload(duplicate).name
    end

    test 'renames every duplicate but the oldest' do
      original = FactoryBot.create(:location, :name => 'dupe')
      second = create_duplicate_of(original)
      third = create_duplicate_of(original)

      migrate_up

      assert_equal 'dupe', reload(original).name
      assert_equal "dupe-#{second.id}", reload(second).name
      assert_equal "dupe-#{third.id}", reload(third).name
    end

    test 'renames duplicates differing only in case' do
      original = FactoryBot.create(:location, :name => 'dupe')
      duplicate = create_duplicate_of(original, name: 'DUPE')

      migrate_up

      assert_equal 'dupe', reload(original).name
      assert_equal "DUPE-#{duplicate.id}", reload(duplicate).name
    end

    test 'renames duplicated children of the same parent' do
      parent = FactoryBot.create(:location, :name => 'ancestor')
      original = FactoryBot.create(:location, :name => 'child', :parent => parent)
      duplicate = create_duplicate_of(original, parent: parent)

      migrate_up

      assert_equal 'child', reload(original).name
      assert_equal "child-#{duplicate.id}", reload(duplicate).name
    end

    test 'picks a free name when the generated one is already taken' do
      original = FactoryBot.create(:location, :name => 'app')
      duplicate = FactoryBot.create(:location, :name => 'placeholder')
      FactoryBot.create(:location, :name => "app-#{duplicate.id}")
      duplicate.update_column(:name, original.name)

      migrate_up

      assert_equal "app-#{duplicate.id}-1", reload(duplicate).name
    end

    test 'keeps the generated name within the column limit' do
      long_name = 'a' * 255
      original = TaxonomyRecord.create!(:type => 'Location', :name => long_name, :title => long_name)
      duplicate = TaxonomyRecord.create!(:type => 'Location', :name => long_name, :title => long_name)

      migrate_up

      new_name = reload(duplicate).name
      assert_equal long_name, reload(original).name
      assert_operator new_name.length, :<=, 255
      assert_not_equal long_name, new_name
    end

    test 'adds the index after the duplicates are resolved' do
      original = FactoryBot.create(:location, :name => 'dupe')
      create_duplicate_of(original)

      migrate_up

      assert index_exists?
    end

    test 'renames root, nested and case-only duplicates from manual repro' do
      root1 = Location.create!(:name => 'prod-east')
      root2 = save_invalid_duplicate(Location.new(:name => 'prod-east'))

      parent = Location.create!(:name => 'aws')
      child1 = parent.children.create!(:name => 'region')
      child2 = save_invalid_duplicate(parent.children.build(:name => 'region'))

      case1 = Location.create!(:name => 'DataCenter')
      case2 = save_invalid_duplicate(Location.new(:name => 'datacenter'))

      migrate_up

      assert_equal 'prod-east', reload(root1).name
      assert_equal "prod-east-#{root2.id}", reload(root2).name

      assert_equal 'region', reload(child1).name
      assert_equal "region-#{child2.id}", reload(child2).name
      assert_equal "aws/region-#{child2.id}", reload(child2).title

      assert_equal 'DataCenter', reload(case1).name
      assert_equal "datacenter-#{case2.id}", reload(case2).name
      assert index_exists?
    end
  end

  context 'rebuilding denormalized titles' do
    test 'rebuilds the title of the renamed location' do
      original = FactoryBot.create(:location, :name => 'group')
      duplicate = create_duplicate_of(original)

      migrate_up

      assert_equal "group-#{duplicate.id}", reload(duplicate).title
    end

    test 'rebuilds the titles of the descendants of the renamed location' do
      original = FactoryBot.create(:location, :name => 'group')
      duplicate = FactoryBot.create(:location, :name => 'placeholder')
      child = FactoryBot.create(:location, :name => 'child', :parent => duplicate)
      grandchild = FactoryBot.create(:location, :name => 'grandchild', :parent => child)
      duplicate.update_column(:name, original.name)

      migrate_up

      renamed = "group-#{duplicate.id}"
      assert_equal renamed, reload(duplicate).title
      assert_equal "#{renamed}/child", reload(child).title
      assert_equal "#{renamed}/child/grandchild", reload(grandchild).title
    end

    test 'keeps the titles of unrelated locations' do
      unrelated = FactoryBot.create(:location, :with_parent, :name => 'unrelated')
      original = FactoryBot.create(:location, :name => 'group')
      create_duplicate_of(original)

      migrate_up

      assert_equal unrelated.title, reload(unrelated).title
    end

    test 'moves the lookup value matchers to the new title' do
      original = FactoryBot.create(:location, :name => 'group')
      duplicate = FactoryBot.create(:location, :name => 'placeholder')
      matcher = create_matcher_for(duplicate)
      duplicate.update_column(:name, original.name)

      migrate_up

      assert_equal "location=group-#{duplicate.id}", matcher.reload.match
    end

    test 'moves the lookup value matchers of the descendants as well' do
      original = FactoryBot.create(:location, :name => 'group')
      duplicate = FactoryBot.create(:location, :name => 'placeholder')
      child = FactoryBot.create(:location, :name => 'child', :parent => duplicate)
      matcher = create_matcher_for(child)
      duplicate.update_column(:name, original.name)

      migrate_up

      assert_equal "location=group-#{duplicate.id}/child", matcher.reload.match
    end

    test 'keeps the lookup value matchers of unrelated locations' do
      unrelated = FactoryBot.create(:location, :name => 'unrelated')
      matcher = create_matcher_for(unrelated)
      original = FactoryBot.create(:location, :name => 'group')
      create_duplicate_of(original)

      migrate_up

      assert_equal 'location=unrelated', matcher.reload.match
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
      FactoryBot.create(:location, :name => 'toplevel')
      migrate_up
      migrate_down

      assert TaxonomyRecord.create!(:type => 'Location', :name => 'toplevel').persisted?
    end

    test 'does not rename anything back' do
      original = FactoryBot.create(:location, :name => 'dupe')
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
    ActiveRecord::Base.connection.index_name_exists?(:taxonomies, INDEX_NAME)
  end

  def create_duplicate_of(taxonomy, name: nil, parent: nil)
    duplicate = FactoryBot.create(taxonomy.class.name.underscore.to_sym, :parent => parent)
    duplicate.update_column(:name, name || taxonomy.name)
    duplicate
  end

  def save_invalid_duplicate(record)
    record.save(:validate => false)
    record
  end

  def create_matcher_for(taxonomy)
    LookupValueRecord.create!(:match => "#{taxonomy.class.name.downcase}=#{taxonomy.title}", :value => 'whatever')
  end

  def reload(taxonomy)
    TaxonomyRecord.find(taxonomy.id)
  end

  def assert_rejected_by_index(&insert)
    assert_raises(ActiveRecord::RecordNotUnique) do
      TaxonomyRecord.transaction(:requires_new => true, &insert)
    end
  end
end
