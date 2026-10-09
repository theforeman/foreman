require 'test_helper'
require Rails.root.join('db/migrate/20261001184900_add_unique_index_to_os_description.rb')

class AddUniqueIndexToOsDescriptionTest < ActiveSupport::TestCase
  INDEX_NAME = 'index_operatingsystems_on_description_unique'

  let(:migration) { AddUniqueIndexToOsDescription.new }

  setup do
    migrate_down if index_exists?
  end

  context 'up' do
    test 'adds the unique index' do
      migrate_up

      assert index_exists?
    end

    test 'normalizes blank descriptions to NULL' do
      os = Operatingsystem.create!(:name => 'BlankDesc', :major => '1', :minor => '0')
      os.update_column(:description, '')

      migrate_up

      assert_nil os.reload.description
    end

    test 'deduplicates descriptions keeping the oldest' do
      older = Operatingsystem.create!(:name => 'Older', :major => '1', :minor => '0', :description => 'Duplicate Desc')
      newer = Operatingsystem.create!(:name => 'Newer', :major => '2', :minor => '0')
      newer.update_column(:description, 'Duplicate Desc')

      migrate_up

      assert_equal 'Duplicate Desc', older.reload.description
      assert_nil newer.reload.description
    end

    test 'rejects duplicate descriptions once the index is in place' do
      Operatingsystem.create!(:name => 'First', :major => '1', :minor => '0', :description => 'Unique Desc')
      migrate_up

      assert_raises(ActiveRecord::RecordNotUnique) do
        Operatingsystem.connection.execute(
          "INSERT INTO operatingsystems (name, major, minor, description, title, type) " \
          "VALUES ('Second', '2', '0', 'Unique Desc', 'Second 2', 'Operatingsystem')"
        )
      end
    end

    test 'allows multiple NULL descriptions' do
      Operatingsystem.create!(:name => 'NoDesc1', :major => '1', :minor => '0')
      Operatingsystem.create!(:name => 'NoDesc2', :major => '2', :minor => '0')
      migrate_up

      assert_nothing_raised do
        Operatingsystem.connection.execute(
          "INSERT INTO operatingsystems (name, major, minor, description, title, type) " \
          "VALUES ('NoDesc3', '3', '0', NULL, 'NoDesc3 3', 'Operatingsystem')"
        )
      end
    end
  end

  context 'down' do
    test 'removes the index' do
      migrate_up
      assert index_exists?

      migrate_down

      refute index_exists?
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
    ActiveRecord::Base.connection.index_name_exists?(:operatingsystems, INDEX_NAME)
  end
end
