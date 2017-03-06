# encoding: utf-8
require 'test_helper'

class DummyController
  cattr_accessor :callbacks
  attr_accessor :organization, :location, :params

  def self.before_action(*args)
    self.callbacks = args
  end

  include Api::TaxonomyScope
end

class ApiTaxonomyScopeTest < ActiveSupport::TestCase
  describe 'include Api::TaxonomyScope' do
    setup do
      @dummy = DummyController.new
      @dummy.params = {:organization_id => taxonomies(:organization1).id, :location_id => taxonomies(:location1).id}
      @org_enabled, SETTINGS[:organizations_enabled] = SETTINGS[:organizations_enabled], true
      @loc_enabled, SETTINGS[:locations_enabled] = SETTINGS[:locations_enabled], true
      Location.current = nil
      Organization.current = nil
    end

    teardown do
      SETTINGS[:locations_enabled] = @loc_enabled
      SETTINGS[:organizations_enabled] = @org_enabled
      users(:one).organizations = []
      users(:one).locations = []
      Location.current = nil
      Organization.current = nil
    end

    test "set_taxonomy_scope respects user association to orgs and locs, fails on not allowed location" do
      Location.expects(:my_locations).returns(Location.where(:id => nil))
      # Organization.expects(:my_organizations).returns(Organization) # locations fails first
      @dummy.expects(:not_found)
      as_user :one do
        @dummy.set_taxonomy_scope
      end
    end

    test "set_taxonomy_scope respects user association to orgs and locs, fails on not allowed organization" do
      Location.expects(:my_locations).returns(Location.where(:id => taxonomies(:location1).id))
      Organization.expects(:my_organizations).returns(Organization.where(:id => nil))
      @dummy.expects(:not_found)
      as_user :one do
        @dummy.set_taxonomy_scope
      end
    end

    test "set_taxonomy_scope respects user association to orgs and locs, sets both if allowed" do
      Location.expects(:my_locations).returns(Location.where(:id => taxonomies(:location1).id))
      Organization.expects(:my_organizations).returns(Organization.where(:id => taxonomies(:organization1).id))
      as_user :one do
        @dummy.set_taxonomy_scope
      end
      assert_equal taxonomies(:organization1), @dummy.organization
      assert_equal taxonomies(:location1), @dummy.location
    end
  end
end
