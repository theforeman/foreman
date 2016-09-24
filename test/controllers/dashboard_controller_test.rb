require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index, {}, set_session_user
    assert_response :success
  end

  test 'create returns 404 if widget to add is not found' do
    post :create, { :name => 'non-existent-widget' }, set_session_user
    assert_response :not_found
  end

  test 'create adds widget to user if widget is valid' do
    assert_difference('users(:admin).widgets.count', 1) do
      post :create, { :name => 'Status table' }, set_session_user
    end
    assert_response :success
  end

  test '#destroy removes a widget from the user' do
    widget = FactoryGirl.create(:widget, :user => users(:admin))
    delete :destroy, { :id => widget.id, :format => 'json' }, set_session_user
    assert_response :success
    assert_equal widget.id.to_s, @response.body
    assert_empty users(:admin).widgets.reload
  end

  test "#destroy returns forbidden for other user's widget" do
    other_user = FactoryGirl.create(:user, :with_widget)
    widget = other_user.widgets.first
    delete :destroy, { :id => widget.id, :format => 'json' }, set_session_user
    assert_response :forbidden
    assert_equal widget.id.to_s, @response.body
    assert_includes other_user.widgets.reload, widget
  end

  test "#reset_to_default resets user's widgets" do
    Dashboard::Manager.expects(:reset_user_to_default).with(users(:admin))
    put :reset_default, {}, set_session_user
    assert_redirected_to root_path
  end

  test "#save_positions updates each widget" do
    widget = FactoryGirl.create(:widget, :user => users(:admin))
    params = {
      widget.id.to_s => {:hide => 'false', :col => '4', :row => '3', :sizex => '8', :sizey => '1'}
    }
    post :save_positions, {:widgets => params, :format => 'json'}, set_session_user
    assert_response :success
    widget.reload
    assert_equal false, widget.hide
    assert_equal 4, widget.col
    assert_equal 3, widget.row
  end
end
