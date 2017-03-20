require 'test_helper'

class Api::V2::ModelsControllerTest < ActionController::TestCase
  valid_attrs = { :name => "new model" }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:models)
  end

  test "should show model" do
    get :show, params: { :id => models(:one).to_param }
    assert_not_nil assigns(:model)
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create model" do
    assert_difference('Model.count', +1) do
      post :create, params: { :model => valid_attrs }
    end
    assert_response :created
    assert_not_nil assigns(:model)
  end

  test "should update model" do
    name = Model.first.name
    put :update, params: { :id => Model.first.to_param, :name => name.to_s.to_param }
    assert_response :success
  end

  test "should destroy model" do
    assert_difference('Model.count', -1) do
      delete :destroy, params: { :id => models(:one).to_param }
    end
    assert_response :success
  end

  test "invalid searches are handled gracefully" do
    get :index, params: { :search => 'notarightterm = wrong' }
    assert_response :bad_request
  end

  test "find model by name even if name starts with integer" do
    model = models(:one)
    new_model = as_admin { Model.create!(:name => "#{model.id}abcdef") }
    assert_equal model.id, new_model.name.to_i
    get :show, params: { :id => new_model.name }
    assert assigns(:model).present?
    assert_equal new_model.id, assigns(:model).id
  end
end
