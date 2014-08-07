require 'test_helper'

class TaxonomixDummy < ActiveRecord::Base
  self.table_name = 'environments'
  attr_accessor :locations, :organizations
  after_initialize :set_taxonomies_to_empty
  include Taxonomix

  def set_taxonomies_to_empty
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

  test "#set_organization to no organizations pre-slected if there are more than one organization" do
    User.current = User.admin
    Organization.current = nil
    assert Organization.my_organizations.count > 0
    @dummy = TaxonomixDummy.new
    assert_equal [], @dummy.organizations
  end

  test "#set_organization to organization pre-slected if there is only one organization" do
    User.current = User.admin
    Organization.current = nil
    Organization.where("name <> ?", 'Organization 1').destroy_all
    assert Organization.my_organizations.count == 1
    @dummy = TaxonomixDummy.new
    assert_equal 1, @dummy.organizations.count
    assert_equal taxonomies(:organization1), @dummy.organizations.first
  end

  test "validation failure if no organizations selected" do
    User.current = User.admin
    assert_equal [], @dummy.organizations
    @dummy.name = "dummy name"
    refute @dummy.save
    assert_equal [:organizations, "You must add at least one organization"], @dummy.errors.first
  end

end
