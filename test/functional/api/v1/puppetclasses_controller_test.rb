require 'test_helper'

class Api::V1::PuppetclassesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'test_puppetclass' }

  test "should get index" do
    get :index, { }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
  end

  test "should create puppetclass" do
    assert_difference('Puppetclass.count') do
      post :create, { :puppetclass => valid_attrs }
    end
    assert_response :success
  end

  test "should update puppetclass" do
    put :update, { :id => puppetclasses(:one).to_param, :puppetclass => { } }
    assert_response :success
  end

  test "should destroy puppetclasss" do
    HostClass.delete_all
    HostgroupClass.delete_all
    assert_difference('Puppetclass.count', -1) do
      delete :destroy, { :id => puppetclasses(:one).to_param }
    end
    assert_response :success
  end

  test "should get puppetclasses for given host only" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert !fact_values.empty?
  end

  test "should not get puppetclasses for nonexistent host" do
    get :index, {"search" => "host = imaginaryhost.nodomain.what" }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert fact_values.empty?
  end

end
