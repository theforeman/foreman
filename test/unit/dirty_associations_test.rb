require 'test_helper'

class DummyDirtyAssociationsModel
  def organization_ids
    @organization_ids ||= []
  end
  attr_writer :organization_ids

  include DirtyAssociations
  dirty_has_many_associations :organizations
end

class DirtyAssociationsTest < ActiveSupport::TestCase
  def setup
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
end
