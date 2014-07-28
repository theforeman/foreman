require 'test_helper'

class Api::V2::ComputeAttributesControllerTest < ActionController::TestCase

  test "should create compute attribute" do
    assert_difference('ComputeAttribute.count') do
      post :create, {:vm_attrs => {"cpus"=>"2", "memory"=>"2147483648"},
                     :compute_profile_id => compute_profiles(:three).id,
                     :compute_resource_id => compute_resources(:one).id
                    }
    end
    assert_response :success
  end

  test "should update compute attribute" do
    put :update, { :id => compute_attributes(:two).id,
                   :compute_profile_id => compute_profiles(:one).id,
                   :compute_resource_id =>compute_resources(:one).id,
                   :vm_attrs => {"cpus"=>"4"}
                 }
    assert_response :success
    assert_equal "4", compute_attributes(:two).reload.vm_attrs['cpus']
  end

end
