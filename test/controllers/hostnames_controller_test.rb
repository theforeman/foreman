require 'test_helper'

class HostnamesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Hostname.any_instance.stubs(:valid?).returns(false)
    post :create, {:hostname => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    post :create, {:hostname => {:name => "MySmartProxy", :hostname => "nowhere.org"}}, set_session_user
    assert_redirected_to hostnames_url
  end

  def test_edit
    get :edit, {:id => Hostname.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Hostname.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Hostname.first.to_param, :hostname => {:hostname => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    put :update, {:id => Hostname.unscoped.first,
                  :hostname => {:hostname => "elsewhere.org"}}, set_session_user
    assert_equal "elsewhere.org", Hostname.unscoped.first.hostname
    assert_redirected_to hostnames_url
  end

  def test_destroy
    hostname = Hostname.first
    delete :destroy, {:id => hostname}, set_session_user
    assert_redirected_to hostnames_url
    assert !Hostname.exists?(hostname.id)
  end

  test "should search by name" do
    @request.env["HTTP_REFERER"] = hostnames_url
    get :index, { :search => "name=\"#{hostnames(:one).name}\"" }, set_session_user
    assert_response :success
    refute_empty assigns(:hostnames)
    assert assigns(:hostnames).include?(hostnames(:one))
  end

  test "should search by smart_proxy" do
    @request.env["HTTP_REFERER"] = hostnames_url
    get :index, { :search => "smart_proxy=\"#{smart_proxies(:one).name}\"" }, set_session_user
    assert_response :success
    refute_empty assigns(:hostnames)
    assert assigns(:hostnames).include?(hostnames(:one))
  end
end
