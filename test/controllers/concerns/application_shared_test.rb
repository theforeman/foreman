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

    test "set_taxonomy respects user association to orgs and locs, sets nil on unknown locations" do
      Location.stubs(:my_locations => Location.where(:id => nil))
      Organization.stubs(:my_organizations => Organization.where(:id => nil))
      as_user :one do
        @dummy.set_taxonomy
      end
      assert_nil Organization.current
      assert_nil Location.current
    end
  end
end
