require 'test_helper'

class DummyDirtyAssociationsModel < ApplicationRecord
  self.table_name = 'dummy_dirty_association'
  def organization_ids
    @organization_ids ||= []
  end
  attr_writer :organization_ids

  include DirtyAssociations
  dirty_has_many_associations :organizations
end

class SecondMock < ApplicationRecord
  self.table_name = 'second_mock'
  belongs_to :first_mock
end

class ThirdMock < ApplicationRecord
  self.table_name = 'third_mock'
  belongs_to :first_mock
end

class FirstMock < ApplicationRecord
  self.table_name = 'first_mock'
  has_many :second_mocks
  has_many :third_mocks

  include DirtyAssociations
  dirty_has_many_associations :second_mocks
  dirty_has_many_associations :third_mocks
end

class DirtyAssociationsTest < ActiveSupport::TestCase
  def setup
    unless ActiveRecord::Base.connection.table_exists? 'first_mock'
      ActiveRecord::Base.connection.create_table :first_mock do |t|
        t.text :name
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'second_mock'
      ActiveRecord::Base.connection.create_table :second_mock do |t|
        t.references :first_mock
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'third_mock'
      ActiveRecord::Base.connection.create_table :third_mock do |t|
        t.references :first_mock
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'dummy_dirty_association'
      ActiveRecord::Base.connection.create_table :dummy_dirty_association do |t|
        t.text :mock_name
      end
    end

    @tester = DummyDirtyAssociationsModel.new
    @tester.organization_ids = [1, 2]
  end

  test "value change sets change flag" do
    assert @tester.organization_ids_changed?
  end

  test "value change stores previous value" do
    assert_equal @tester.organization_ids_was, []
    @tester.organization_ids = [3]
    assert_equal @tester.organization_ids_was, [1, 2]
  end

  test "association setter accepts single ids too" do
    @tester.organization_ids = 3
    assert_equal @tester.organization_ids, [3]
  end

  test "should return false if nothing _changed?" do
    @tester = DummyDirtyAssociationsModel.new
    refute @tester.organization_ids_changed?
  end

  test "_changed? should return false after saving" do
    @first_mock = FirstMock.create(name: "test1")
    @second_mock = SecondMock.create(first_mock_id: 1)
    @third_mock = ThirdMock.create(first_mock_id: 1)

    @first_mock.second_mock_ids = []
    @first_mock.third_mock_ids = []

    assert @first_mock.second_mock_ids_changed?
    assert @first_mock.third_mock_ids_changed?

    @first_mock.save!

    refute @first_mock.second_mock_ids_changed?
    refute @first_mock.third_mock_ids_changed?
  end
end
