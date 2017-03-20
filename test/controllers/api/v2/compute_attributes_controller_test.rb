require 'test_helper'

class Api::V2::ComputeAttributesControllerTest < ActionController::TestCase
  test "should create compute attribute" do
    assert_difference('ComputeAttribute.count') do
      valid_attrs = {:vm_attrs => {"cpus"=>"2", "memory"=>"2147483648"}}
      post :create, params: { :compute_attribute => valid_attrs,
                              :compute_profile_id => compute_profiles(:three).id,
                              :compute_resource_id => compute_resources(:one).id }
    end
    assert_response :created
  end

  test "should update compute attribute" do
    valid_attrs = {:vm_attrs => {"cpus"=>"4"}}
    put :update, params: { :id => compute_attributes(:two).id,
                           :compute_profile_id => compute_profiles(:one).id,
                           :compute_resource_id =>compute_resources(:one).id,
                           :compute_attribute => valid_attrs }
    assert_response :success
    assert_equal "4", compute_attributes(:two).reload.vm_attrs['cpus']
  end
end
