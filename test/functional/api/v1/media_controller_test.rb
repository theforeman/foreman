require 'test_helper'

class Api::V1::MediaControllerTest < ActionController::TestCase


  new_medium = {
      :name => "new medium",
      :path => "http://www.newmedium.com/",
    }

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:media)

  end

  test "should show medium" do
    as_user :admin do
      get :show, {:id => media(:one).to_param}
    end
    assert_not_nil assigns(:medium)
    assert_response :success
  end

  test "should create medium" do
    as_user :admin do
      assert_difference('Medium.count', +1) do
        post :create, {:medium => new_medium}
      end
    end
    assert_response :created
    assert_not_nil assigns(:medium)
  end

  test "should update medium" do
    name = Medium.first.name
    as_user :admin do
      put :update, {:id => Medium.first.id.to_param, :name => "#{name}".to_param }
    end
    assert_response :success
  end

  test "should destroy medium" do
    id = Medium.first.id
    puts "id:#{id}"
    as_admin do
      assert_difference('Medium.count', -1) do
              delete :destroy, {:id => media(:unused).id.to_param}
      end
    end
    assert_response :success

  end

end