require 'test_helper'

class ModelsControllerTest < ActionController::TestCase
  def test_create_valid
    Model.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :model => {:name => "test"} }, session: set_session_user
    assert_redirected_to models_url
  end

  def test_update_valid
    Model.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => Model.first, :model => {:name => "updated test"} }, session: set_session_user
    assert_redirected_to models_url
  end

  def test_destroy
    model = Model.first
    delete :destroy, params: { :id => model }, session: set_session_user
    assert_redirected_to models_url
    assert !Model.exists?(model.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a model' do
    setup_user
    put :update, params: { :id => Model.first.id, :model => { :name => 'x' } }, session: set_session_user.merge(:user => users(:one).id)
    assert_response :forbidden
  end
end
