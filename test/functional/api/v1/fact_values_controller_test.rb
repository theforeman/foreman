require 'test_helper'

class Api::V1::FactValuesControllerTest < ActionController::TestCase
  def setup
    @host = FactoryGirl.create(:host)
    FactoryGirl.create(:fact_value, :value => '2.6.9',:host => @host,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'kernelversion'))
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    refute_empty fact_values
  end

  test "should get facts for given host only" do
    get :index, {:host_id => @host.name }
    assert_response :success
    fact_values   = ActiveSupport::JSON.decode(@response.body)
    expected_hash = FactValue.build_facts_hash(FactValue.where(:host_id => @host.id))
    assert_equal expected_hash, fact_values
  end

  test "should get facts for given host id" do
    get :index, {:host_id => @host.id }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    expected_hash = FactValue.build_facts_hash(FactValue.where(:host_id => @host.id))
    assert_equal expected_hash, fact_values
  end

  test "should get facts as non-admin user with joined search" do
    setup_user
    @host.update_attribute(:hostgroup, FactoryGirl.create(:hostgroup))
    as_user(users(:one)) do
      get :index, {:search => "host.hostgroup = #{@host.hostgroup.name}"}
    end
    assert_response :success
    fact_values   = ActiveSupport::JSON.decode(@response.body)
    expected_hash = FactValue.build_facts_hash(FactValue.where(:host_id => @host.id))
    assert_equal expected_hash, fact_values
  end

  private

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end
end