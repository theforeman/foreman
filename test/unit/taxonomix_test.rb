require 'test_helper'

class TaxonomixDummy
  include Taxonomix::InstanceMethods

  attr_accessor :locations, :organizations

  def new_record?
    true
  end

  def errors
    OpenStruct.new :empty? => true
  end

  def initialize
    self.locations = []
    self.organizations = []
  end
end

class TaxonomixTest < ActiveSupport::TestCase
  def setup
    @dummy = TaxonomixDummy.new
    Taxonomy.stubs(:enabled?).with(:location).returns(false)
    Taxonomy.stubs(:enabled?).with(:organization).returns(true)
  end

  test "#add_current_taxonomy? returns false for disabled taxonomy" do
    refute @dummy.add_current_taxonomy?(:location)
  end

  test "#add_current_taxonomy? returns false for unset current taxonomy" do
    Organization.stubs(:current).returns(nil)
    refute @dummy.add_current_taxonomy?(:organization)
  end

  test "#add_current_taxonomy? returns false when current taxonomy already assigned" do
    Organization.stubs(:current).returns(taxonomies(:organization1))
    @dummy.organizations = [taxonomies(:organization1)]
    refute @dummy.add_current_taxonomy?(:organization)
  end

  test "#add_current_taxonomy? returns true otherwise" do
    Organization.stubs(:current).returns(taxonomies(:organization1))
    Organization.stubs(:organizations).returns([])
    assert @dummy.add_current_taxonomy?(:organization)
  end

  test "#set_current_taxonomy" do
    Organization.stubs(:current).returns(taxonomies(:organization1))
    @dummy.set_current_taxonomy
    assert_includes @dummy.organizations, taxonomies(:organization1)
    assert_empty @dummy.locations
  end
end
