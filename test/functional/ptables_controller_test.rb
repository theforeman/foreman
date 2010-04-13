require 'test_helper'

class PtablesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Ptable.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Ptable.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Ptable.any_instance.stubs(:valid?).returns(true)
    post :create, :ptable => {:name => "dummy", :layout => "dummy"}
    assert_redirected_to ptable_url(assigns(:ptable))
  end

  def test_edit
    get :edit, :id => Ptable.first
    assert_template 'edit'
  end

  def test_update_invalid
    Ptable.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Ptable.first
    assert_template 'edit'
  end

  def test_update_valid
    Ptable.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Ptable.first
    assert_redirected_to ptable_url(assigns(:ptable))
  end

  def test_destroy
    ptable = Ptable.first
    delete :destroy, :id => ptable
    assert_redirected_to ptables_url
    assert !Ptable.exists?(ptable.id)
  end
end
