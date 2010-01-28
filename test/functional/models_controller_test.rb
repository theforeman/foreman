require 'test_helper'

class ModelsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create new model" do
    assert_difference 'Model.count' do
      post :create, { :commit => "create", :record => {:name => "generic"} }
    end
  end

  test "should get edit" do
    model = Model.new :name => "generic"
    assert model.save!

    get :edit, :id => model.id
    assert_response :success
  end

  test "should update model" do
    model = Model.new :name => "generic"
    assert model.save!

    put :update, { :commit => "Update", :id => model.id, :record => {:name => "not_generic"} }
    up_model = Model.find_by_id(model.id)
    assert up_model.name == "not_generic"
  end

  test "should destroy model" do
    model = Model.new :name => "generic"
    assert model.save!

    assert_difference('Model.count', -1) do
      delete :destroy, :id => model.id
    end
  end
end
