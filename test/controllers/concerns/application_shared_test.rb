require 'test_helper'

class DummyController < ActionController::Base
  cattr_accessor :callbacks
  attr_accessor :organization, :location, :params

  def self.before_action(*args)
    self.callbacks = args
  end

  def self.around_action(*args)
    # noop
  end

  def api_request?
    true
  end

  def session
    @session ||= {}
  end

  def request
    @request ||= Struct.new(:session).new(:session => session)
  end

  include ApplicationShared
end

class ApplicationSharedTest < ActiveSupport::TestCase
  describe 'include ApplicationShared' do
    setup do
      @dummy = DummyController.new
      @dummy.params = {:organization_id => taxonomies(:organization1).id, :location_id => taxonomies(:location1).id}.with_indifferent_access
      Location.current = nil
      Organization.current = nil
    end

    teardown do
      users(:one).organizations = []
      users(:one).locations = []
      Location.current = nil
      Organization.current = nil
    end

    test "set_taxonomy respects user association to orgs and locs, sets nil on unknown locations" do
      Location.stubs(:my_locations => Location.where(:id => nil))
      Organization.stubs(:my_organizations => Organization.where(:id => nil))
      @dummy.expects(:not_found)
      as_user :one do
        @dummy.set_taxonomy
      end
      assert_nil Organization.current
      assert_nil Location.current
    end

    test "set_taxonomy resolves organization_id/location_id params to the taxonomies the user has access to" do
      as_user :one do
        @dummy.set_taxonomy
      end
      assert_equal taxonomies(:organization1), Organization.current
      assert_equal taxonomies(:location1), Location.current
    end

    test "set_taxonomy rejects an organization_id param the user has no access to" do
      @dummy.params = {:organization_id => taxonomies(:organization2).id}.with_indifferent_access
      @dummy.expects(:not_found)
      as_user :one do
        @dummy.set_taxonomy
      end
      assert_nil Organization.current
    end

    test "set_taxonomy rejects a location_id param the user has no access to" do
      @dummy.params = {:location_id => taxonomies(:location2).id}.with_indifferent_access
      @dummy.expects(:not_found)
      as_user :one do
        @dummy.set_taxonomy
      end
      assert_nil Location.current
    end
  end
end
