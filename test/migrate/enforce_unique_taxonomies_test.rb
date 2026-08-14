require 'test_helper'
require Rails.root.join('db/migrate/20260814125426_enforce_unique_taxonomies.rb')

class EnforceUniqueTaxonomiesTest < ActiveSupport::TestCase
  let(:migration) { EnforceUniqueTaxonomies.new }

  setup do
    # CI runs db:migrate before the suite, so this migration's unique index
    # already exists. Drop it so migration.up sees the pre-migration state.
    ActiveRecord::Base.connection.remove_index(:taxonomies, :name => 'index_taxonomies_on_type_ancestry_lower_name')
  end

  def duplicate_location(name)
    location = Location.new(:name => name)
    location.save(:validate => false)
    location
  end

  test "adds a unique index that rejects further duplicates" do
    migration.up

    location = duplicate_location('Post-migration Location')
    duplicate = Location.new(:name => location.name)

    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate.save(:validate => false)
    end
  end

  test "aborts when duplicate names already exist, without deleting them" do
    first = duplicate_location('Race Location')
    second = duplicate_location('Race Location')

    error = assert_raises(RuntimeError) { migration.up }
    assert_match(/ids=#{first.id}, #{second.id}/, error.message)
    assert Location.exists?(id: first.id)
    assert Location.exists?(id: second.id)
    assert_not ActiveRecord::Base.connection.index_exists?(:taxonomies, name: 'index_taxonomies_on_type_ancestry_lower_name')
  end

  test "migration is reversible" do
    migration.up
    migration.down

    location = duplicate_location('Post-rollback Location')
    duplicate = Location.new(:name => location.name)

    assert_nothing_raised do
      duplicate.save(:validate => false)
    end
  end
end
