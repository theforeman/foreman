require 'test_helper'

class ArchitecturesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to architectures_url
  end

  def test_edit
    get :edit, {:id => Architecture.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Architecture.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Architecture.first.name}, set_session_user
    assert_redirected_to architectures_url
  end

  def test_destroy
    architecture = Architecture.first
    architecture.hosts = []
    delete :destroy, {:id => architecture.name}, set_session_user
    assert_redirected_to architectures_url
    assert !Architecture.exists?(architecture.id)
  end
end
