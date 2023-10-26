require 'test_helper'

class BulkHostsExtensionTestController < ::Api::BaseController
  include Api::Version2
  include ::Api::V2::BulkHostsExtension

  def initialize(params = {})
    @params = params
  end

  attr_reader :params
end

class BulkHostsExtensionTest < ActiveSupport::TestCase
  def models
    as_admin do
      @organization = FactoryBot.create(:organization)
      @host1 = FactoryBot.create(:host, :managed, :organization => @organization)
      @host2 = FactoryBot.create(:host, :organization => @organization)
      @host3 = FactoryBot.create(:host, :organization => @organization)
      @host4 = FactoryBot.create(:host, :organization => @organization)
      @host5 = FactoryBot.create(:host, :organization => @organization)
      @host6 = FactoryBot.create(:host, :organization => @organization)
      @host_ids = [@host1, @host2, @host3, @host4, @host5, @host6].map(&:id)
    end
  end

  def permissions
    @edit = :edit_hosts
  end

  def setup
    # set_user
    models
    permissions
    @controller = BulkHostsExtensionTestController.new(organization_id: @organization.id)
  end

  def test_search
    bulk_params = {
      :included => {
        :search => "name = #{@host1.name}",
      },
    }
    result = @controller.find_bulk_hosts(@edit, bulk_params)

    assert_equal result, [@host1]
  end

  def test_search_restrict
    bulk_params = {
      :included => {
        :search => "name ~ host",
      },
    }
    restrict = ->(hosts) { hosts.where("id != #{@host2.id}") }
    result = @controller.find_bulk_hosts(@edit, bulk_params, restrict)

    assert_includes result, @host1
    refute_includes result, @host2
    assert_includes result, @host3
  end

  def test_search_exclude
    bulk_params = {
      :included => {
        :search => "name ~ host",
      },
    :excluded => {
      :ids => [@host1.id],
    },
    }
    result = @controller.find_bulk_hosts(@edit, bulk_params)

    refute_includes result, @host1
    assert_includes result, @host2
    assert_includes result, @host3
  end

  def test_no_hosts_specified
    bulk_params = {
      :included => {},
    }
    @controller.expects(:render_error).with(:custom_error, :status => :bad_request, :locals => { :message => _('No hosts have been specified') })
    @controller.find_bulk_hosts(@edit, bulk_params)
  end

  def test_ids
    bulk_params = {
      :included => {
        :ids => [@host1.id, @host2.id],
      },
    }
    result = @controller.find_bulk_hosts(@edit, bulk_params)

    assert_equal [@host1, @host2].sort, result.sort
  end

  def test_ids_excluded
    bulk_params = {
      :included => {
        :ids => [@host1.id, @host2.id],
      },
      :excluded => {
        :ids => [@host2.id],
      },
    }
    result = @controller.find_bulk_hosts(@edit, bulk_params)

    assert_equal result, [@host1]
  end

  def test_ids_restricted
    bulk_params = {
      :included => {
        :ids => [@host1.id, @host2.id],
      },
    }
    restrict = ->(hosts) { hosts.where("id != #{@host2.id}") }
    result = @controller.find_bulk_hosts(@edit, bulk_params, restrict)

    assert_equal result, [@host1]
  end

  def test_included_ids_with_nil_scoped_search
    bulk_params = {
      :included => {
        :ids => [@host1.id, @host2.id],
        :search => nil,
      },
    }

    result = @controller.find_bulk_hosts(@edit, bulk_params)

    assert_equal [@host1, @host2].sort, result.sort
  end

  def test_ids_with_scoped_search
    bulk_params = {
      :included => {
        :ids => [@host1.id, @host2.id],
        :search => "name != #{@host2.name}",
      },
    }

    result = @controller.find_bulk_hosts(@edit, bulk_params)

    assert_equal result, [@host1]
  end

  def test_forbidden
    bulk_params = {
      :included => {
        :ids => [@host1.id],
      },
      :excluded => {
        :ids => [@host1.id],
      },
    }
    @controller.expects(:render_error).with(:custom_error, :status => :forbidden, :locals => { :message => _('No hosts matched search, or action unauthorized for selected hosts.') })
    @controller.find_bulk_hosts(@edit, bulk_params)
  end

  def test_empty_params
    @controller.expects(:render_error).with(:custom_error, :status => :bad_request, :locals => { :message => _('No hosts have been specified') })
    @controller.find_bulk_hosts(@edit, {})
  end
end
