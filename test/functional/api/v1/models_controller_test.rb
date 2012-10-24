require 'test_helper'

class Api::V1::ModelsControllerTest < ActionController::TestCase

  valid_attrs = { :name => "new model" }

  test "should get index" do
    as_user :admin do
      get :index, { }
    end
    assert_response :success
    assert_not_nil assigns(:models)
  end

  test "should show model" do
    as_user :admin do
      get :show, { :id => models(:one).to_param }
    end
    assert_not_nil assigns(:model)
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create model" do
    as_user :admin do
      assert_difference('Model.count', +1) do
        post :create, { :model => valid_attrs }
      end
    end
    assert_response :created
    assert_not_nil assigns(:model)
  end

  test "should update model" do
    name = Model.first.name
    as_user :admin do
      put :update, { :id => Model.first.to_param, :name => "#{name}".to_param }
    end
    assert_response :success
  end

  test "should destroy model" do
    id = Model.first.id
    as_admin do
      assert_difference('Model.count', -1) do
        delete :destroy, { :id => models(:one).to_param }
      end
    end
    assert_response :success
  end

end
