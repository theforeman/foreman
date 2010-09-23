require 'test_helper'

class PtablesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_show_json
    get :show, {:id => Ptable.first.id}, :format => :json, :user => users(:admin).id
    json = ActiveSupport::JSON.decode(@response.body)
    assert_equal "default", json["ptable"]["name"]
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Ptable.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Ptable.any_instance.stubs(:valid?).returns(true)
    post :create, {:ptable => {:name => "dummy", :layout => "dummy"}}, set_session_user
    assert_redirected_to ptable_url(assigns(:ptable))
  end

  def test_edit
    get :edit, {:id => Ptable.first.id}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Ptable.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Ptable.first.id}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Ptable.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Ptable.first.id}, set_session_user
    assert_redirected_to ptable_url(assigns(:ptable))
  end

  def test_destroy
    ptable = Ptable.first
    delete :destroy, {:id => ptable.id}, set_session_user
    assert_redirected_to ptables_url
    assert !Ptable.exists?(ptable.id)
  end
end
