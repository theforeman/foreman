require 'test_helper'

class Api::V2::ComputeAttributesControllerTest < ActionController::TestCase
  def setup
    Fog.mock!
  end

  def teardown
    Fog.unmock!
  end

  test "index content is a JSON array" do
    get :index
    compute_attributes = ActiveSupport::JSON.decode(@response.body)
    assert compute_attributes['results'].is_a?(Array)
    assert_response :success
    assert !compute_attributes.empty?
  end

  test "should create compute attribute" do
    assert_difference('ComputeAttribute.count') do
      ComputeAttribute.any_instance.stubs(:new_vm).returns(nil)
      valid_attrs = {:vm_attrs => {"cpus" => "2", "memory" => "2147483648"}}
      post :create, params: { :compute_attribute => valid_attrs,
                              :compute_profile_id => compute_profiles(:three).id,
                              :compute_resource_id => compute_resources(:one).id }
    end
    assert_response :created
  end

  test "should show compute attribute" do
    get :show, params: { :id => compute_attributes(:two).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update compute attribute" do
    valid_attrs = {:vm_attrs => {"cpus" => "4"}}
    ComputeAttribute.any_instance.stubs(:new_vm).returns(nil)
    put :update, params: { :id => compute_attributes(:two).id,
                           :compute_profile_id => compute_profiles(:one).id,
                           :compute_resource_id => compute_resources(:one).id,
                           :compute_attribute => valid_attrs }
    assert_response :success
    assert_equal "4", compute_attributes(:two).reload.vm_attrs['cpus']
  end
end
