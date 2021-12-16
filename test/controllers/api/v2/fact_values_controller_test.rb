require 'test_helper'

class Api::V2::FactValuesControllerTest < ActionController::TestCase
  def setup
    @organization1 = FactoryBot.create(:organization)
    @location1 = FactoryBot.create(:location)

    @host = FactoryBot.create(:host, :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    @host2 = FactoryBot.create(:host, :organization => @organization1, :location => @location1)

    FactoryBot.create(:fact_value, :value => '2.6.9', :host => @host,
                       :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))

    FactoryBot.create(:fact_value, :value => 'Fedora', :host => @host2,
                      :fact_name => FactoryBot.create(:fact_name, :name => 'os'))
  end

  test "should get index" do
    get :index
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = {@host.name => {"kernelversion" => "2.6.9"}, @host2.name => {"os" => "Fedora"}}
    assert_equal expected_hash, fact_values
  end

  test "should get facts for given host only" do
    get :index, params: { :host_id => @host.name }
    assert_response :success
    fact_values   = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = {@host.name => {"kernelversion" => "2.6.9"}}
    assert_equal expected_hash, fact_values
  end

  test "should get facts for given host id" do
    get :index, params: { :host_id => @host.id }
    assert_response :success
    fact_values   = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = {@host.name => {"kernelversion" => "2.6.9"}}
    assert_equal expected_hash, fact_values
  end

  test "should get facts as non-admin user with joined search" do
    setup_user
    @host.update_attribute(:hostgroup, FactoryBot.create(:hostgroup))
    as_user(users(:one)) do
      get :index, params: { :search => "host.hostgroup = #{@host.hostgroup.name}" }
    end
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = {@host.name => {"kernelversion" => "2.6.9"}}
    assert_equal expected_hash, fact_values
  end

  test "should return empty result in case host doesn't exists" do
    get :index, params: {:host_id => 9000}
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = {}
    assert_equal expected_hash, fact_values
  end

  test "should search facts by location" do
    skip "Randomly fails: https://projects.theforeman.org/issues/25398"
    get :index, params: { "location_id" => @host.location_id }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = {@host.name => {"kernelversion" => "2.6.9"}}
    assert_equal expected_hash, fact_values
  end

  test "should search facts by organiztion" do
    skip "Randomly fails: https://projects.theforeman.org/issues/25398"
    get :index, params: { "organization_id" => @host.organization_id }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = {@host.name => {"kernelversion" => "2.6.9"}}
    assert_equal expected_hash, fact_values
  end

  private

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end
end
