require 'test_helper'

class ModelsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Model.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Model.any_instance.stubs(:valid?).returns(true)
    post :create, :model => {:name => "test"}
    assert_redirected_to models_url
  end

  def test_edit
    get :edit, :id => Model.first
    assert_template 'edit'
  end

  def test_update_invalid
    Model.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Model.first
    assert_template 'edit'
  end

  def test_update_valid
    Model.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Model.first
    assert_redirected_to models_url
  end

  def test_destroy
    model = Model.first
    delete :destroy, :id => model
    assert_redirected_to models_url
    assert !Model.exists?(model.id)
  end
end
