require 'test_helper'

class GlobalLookupKeysControllerTest < ActionController::TestCase
  def setup
    GlobalLookupKey.create :key => "some_parameter", :default_value => ""
  end

  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    GlobalLookupKey.any_instance.stubs(:valid?).returns(false)
    post :create, {:global_lookup_key => {:key => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    GlobalLookupKey.any_instance.stubs(:valid?).returns(true)
    post :create, {:global_lookup_key => {:key => GlobalLookupKey.first.key}}, set_session_user
    assert_redirected_to global_lookup_keys_url
  end

  def test_edit
    get :edit, {:id => GlobalLookupKey.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    GlobalLookupKey.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => GlobalLookupKey.first, :global_lookup_key => {:key => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    GlobalLookupKey.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => GlobalLookupKey.first, :global_lookup_key => {:key => "Reference", :default_value => "foreman"}}, set_session_user
    assert_redirected_to global_lookup_keys_url
  end

  def test_destroy
    global_lookup_key = GlobalLookupKey.first
    delete :destroy, {:id => global_lookup_key}, set_session_user
    assert_redirected_to global_lookup_keys_url
    assert !GlobalLookupKey.exists?(global_lookup_key.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  context 'user with viewer rights' do
    def user_with_viewer_rights_should_fail_to_edit_a_global_lookup_key
      setup_user
      get :edit, {:id => GlobalLookupKey.first.id}
      assert @response.status == '403 Forbidden'
    end

    def user_with_viewer_rights_should_succeed_in_viewing_global_lookup_key
      setup_user
      get :index
      assert_response :success
    end
  end
end
