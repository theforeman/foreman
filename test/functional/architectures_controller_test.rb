require 'test_helper'

class ArchitecturesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Architecture.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to architecture_url(assigns(:architecture))
  end
  
  def test_edit
    get :edit, :id => Architecture.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Architecture.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Architecture.first
    assert_redirected_to architecture_url(assigns(:architecture))
  end
  
  def test_destroy
    architecture = Architecture.first
    delete :destroy, :id => architecture
    assert_redirected_to architectures_url
    assert !Architecture.exists?(architecture.id)
  end
end
