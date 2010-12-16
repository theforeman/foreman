require 'test_helper'

class SmartProxiesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    SmartProxy.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    SmartProxy.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to smart_proxies_url
  end

  def test_edit
    get :edit, :id => SmartProxy.first
    assert_template 'edit'
  end

  def test_update_invalid
    SmartProxy.any_instance.stubs(:valid?).returns(false)
    put :update, :id => SmartProxy.first
    assert_template 'edit'
  end

  def test_update_valid
    SmartProxy.any_instance.stubs(:valid?).returns(true)
    put :update, :id => SmartProxy.first
    assert_redirected_to smart_proxies_url
  end

  def test_destroy
    proxy = SmartProxy.first
    proxy.subnets.clear
    proxy.domains.clear
    delete :destroy, :id => proxy
    assert_redirected_to smart_proxies_url
    assert !SmartProxy.exists?(proxy.id)
  end
end
