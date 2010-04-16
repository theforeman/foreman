require 'test_helper'

class OperatingsystemsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Operatingsystem.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Operatingsystem.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to operatingsystems_url
  end

  def test_edit
    get :edit, {:id => Operatingsystem.first}, set_session_user
    assert_template 'edit'
  end
  def test_update_invalid
    Operatingsystem.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Operatingsystem.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Operatingsystem.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Operatingsystem.first}, set_session_user
    assert_redirected_to operatingsystems_url
  end

  def test_destroy
    operatingsystem = Operatingsystem.first
    delete :destroy, {:id => operatingsystem}, set_session_user
    assert_redirected_to operatingsystems_url
    assert !Operatingsystem.exists?(operatingsystem.id)
  end
end
