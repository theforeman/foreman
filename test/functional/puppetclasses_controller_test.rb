require 'test_helper'

class PuppetclassesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Puppetclass.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Puppetclass.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to puppetclasses_url
  end

  def test_edit
    get :edit, {:id => Puppetclass.first.to_param}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Puppetclass.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Puppetclass.first.to_param}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Puppetclass.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Puppetclass.first.to_param}, set_session_user
    assert_redirected_to puppetclasses_url
  end

  def test_destroy
    puppetclass = Puppetclass.first
    delete :destroy, {:id => puppetclass.to_param}, set_session_user
    assert_redirected_to puppetclasses_url
    assert !Puppetclass.exists?(puppetclass.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a puppetclass' do
    setup_user
    get :edit, {:id => Puppetclass.first.to_param}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should succeed in viewing puppetclasses' do
    setup_user
    get :index
    assert_response :success
  end
end
