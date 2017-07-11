require 'test_helper'

class ComputeAttributesControllerTest < ActionController::TestCase
  setup do
    Fog.mock!
    User.current = users :admin
    @set = compute_attributes(:one)
    @compute_profile = @set.compute_profile #1-Small
    @compute_resource = @set.compute_resource #EC2
  end

  teardown do
    Fog.unmock!
  end

  test "should get new" do
    get :new, {:compute_profile_id => @compute_profile.to_param, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should create compute_attribute" do
    assert_difference('ComputeAttribute.count') do
      # create 3-Large that doesn't exist in fixtures
      post :create, {:compute_profile_id => @compute_profile.to_param,
                    :compute_attribute => { :compute_resource_id => @compute_resource.to_param, :compute_profile_id => compute_profiles(:three), :vm_attrs => {"flavor_id"=>"t2.medium"} }}, set_session_user
    end
    assert_redirected_to compute_profile_path(assigns(:set).compute_profile)
    assert_equal "t2.medium", assigns(:set).vm_attrs['flavor_id']
  end

  test "should get edit" do
    get :edit, {:compute_profile_id => @compute_profile.to_param, :id => @set}, set_session_user
    assert_response :success
  end

  test "should update compute_attribute" do
    put :update, {:id => @set,
                  :compute_profile_id => @compute_profile.to_param,
                  :compute_attribute => { :compute_resource_id => @set.compute_resource_id, :compute_profile_id => @set.compute_profile_id, :vm_attrs => {"flavor_id"=>"t2.medium"} }}, set_session_user
    assert_redirected_to compute_profile_path(@set.compute_profile)
    assert_equal "t2.medium", compute_attributes(:one).reload.vm_attrs['flavor_id']
  end

  test "should update compute_attribute with scsi normalization" do
    #rubocop:disable Metrics/LineLength
    json_scsi_data = "{\"scsiControllers\":[{\"type\":\"VirtualLsiLogicController\",\"key\":1000}],\"volumes\":[{\"thin\":true,\"name\":\"Hard disk\",\"mode\":\"persistent\",\"controllerKey\":1000,\"size\":10485760,\"sizeGb\":10,\"storagePod\":\"POD-ZERO\"},{\"sizeGb\":10,\"datastore\":\"\",\"storagePod\":\"POD-ZERO\",\"thin\":false,\"eagerZero\":false,\"name\":\"Hard disk\",\"mode\":\"persistent\",\"controllerKey\":1000}]}"
    #rubocop:enable Metrics/LineLength
    put :update, {
      :id => @set,
      :compute_profile_id => @compute_profile.to_param,
      :compute_attribute => {
        :compute_resource_id => @set.compute_resource_id,
        :compute_profile_id => @set.compute_profile_id,
        :vm_attrs => {"scsi_controllers" => json_scsi_data}
      }
    }, set_session_user
    saved_attrs = compute_attributes(:one).reload.vm_attrs
    assert_equal [{"type"=>"VirtualLsiLogicController", "key"=>1000}], saved_attrs['scsi_controllers']
    volumes_attrs = {
      '0' => {
        'thin' => true,
        'name' => 'Hard disk',
        'mode' => 'persistent',
        'controller_key' => 1000,
        'size' => 10485760,
        'size_gb' => 10,
        'storage_pod' => 'POD-ZERO'
      },
      '1' => {
        'size_gb' => 10,
        'datastore' => '',
        'storage_pod' => 'POD-ZERO',
        'thin' => false,
        'eager_zero' => false,
        'name' => 'Hard disk',
        'mode' => 'persistent',
        'controller_key' => 1000
      }
    }
    assert_equal volumes_attrs, saved_attrs['volumes_attributes']
  end
end
