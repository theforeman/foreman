require 'test_helper'

class Api::V2::FactValuesControllerTest < ActionController::TestCase
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
    fact_values   = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = FactValue.build_facts_hash(FactValue.where(:host_id => @host.id))
    assert_equal expected_hash, fact_values
  end

  test "should get facts for given host id" do
    get :index, {:host_id => @host.id }
    assert_response :success
    fact_values   = ActiveSupport::JSON.decode(@response.body)['results']
    expected_hash = FactValue.build_facts_hash(FactValue.where(:host_id => @host.id))
    assert_equal expected_hash, fact_values
  end
end
