require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  test "#unlimited?" do
    f = Factory.build :filter
    assert_nil f.search, 'default filter is not unlimited'
    assert f.unlimited?
  end

  test "#limited?" do
    f = Factory.build :filter, :on_name_all
    refute_nil f.search, 'filter is not limited'
    assert f.limited?
  end

  test "#limited? even for empty string" do
    f = Factory.build :filter
    f.search = ''
    assert f.limited?
  end

  test ".limited" do
    f = Factory.create(:filter, :on_name_all)
    assert_include Filter.limited, f
  end

  test ".unlimited" do
    f = Factory.create(:filter)
    assert_include Filter.unlimited, f
  end

  test "#resource_type for empty permissions collection" do
    f = Factory.build(:filter)
    assert_nil f.resource_type
  end

  test "#resource_type" do
    f = Factory.build(:filter)
    f.stub :permissions, [ OpenStruct.new(:resource_type => 'test') ] do
      assert_equal 'test', f.resource_type
    end
  end

  test "unlimited filters have nilified search string" do
    f = Factory.build(:filter, :search => 'name ~ a*', :unlimited => '1')
    assert f.valid?
    assert_nil f.search

    f = Factory.build(:filter, :search => '', :unlimited => '1')
    assert f.valid?
    assert_nil f.search

    f = Factory.build(:filter, :search => 'name ~ a*', :unlimited => '0')
    assert f.valid?
    assert_equal 'name ~ a*', f.search
  end
end
