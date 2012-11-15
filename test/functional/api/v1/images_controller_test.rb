require 'test_helper'

class Api::V1::ImagesControllerTest < ActionController::TestCase

  valid_attrs = {:name => 'TestImage', :username => 'ec2-user', :uuid => 'abcdef', 
        :operatingsystem_id => Operatingsystem.first.id,
        :compute_resource_id => ComputeResource.first.id,
        :architecture_id => Architecture.first.id,        
      }
  test "should get index" do
    as_user :admin do
      get :index, {:compute_resource_id => images(:two).compute_resource_id}
    end
    assert_response :success
    assert_not_nil assigns(:images)
    images = ActiveSupport::JSON.decode(@response.body)
    assert !images.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:compute_resource_id => images(:two).compute_resource_id, :id => images(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create image" do
    as_user :admin do
      assert_difference('Image.count') do
        post :create, {:compute_resource_id => images(:two).compute_resource_id, :image => valid_attrs}
      end
    end
    assert_response :success
  end

  test "should update image" do
    as_user :admin do
      put :update, {:compute_resource_id => images(:two).compute_resource_id, :id => images(:one).to_param, :image => {} }
    end
    assert_response :success
  end

  test "should destroy images" do
    as_user :admin do
      assert_difference('Image.count', -1) do
        delete :destroy, {:compute_resource_id => images(:two).compute_resource_id, :id => images(:one).to_param}
      end
    end
    assert_response :success
  end

end
