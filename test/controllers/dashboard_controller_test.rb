require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  let(:any_default_widget) { Dashboard::Manager.default_widgets.sample }

  test 'should get index' do
    get :index, session: set_session_user
    assert_response :success
  end

  test 'create returns 404 if widget to add is not found' do
    post :create, params: { :name => 'non-existent-widget' }, session: set_session_user
    assert_response :not_found
  end

  test 'create adds widget to user if widget is valid' do
    assert_difference('users(:admin).widgets.count', 1) do
      post :create, params: { :name => any_default_widget[:name] },
                    session: set_session_user
    end
    assert_response :success
  end

  test '#destroy removes a widget from the user' do
    widget = FactoryBot.create(:widget, :user => users(:admin))
    assert_includes users(:admin).widget_ids, widget.id
    delete :destroy, params: { :id => widget.id, :format => 'json' }, session: set_session_user
    assert_response :success
    assert_equal widget.id.to_s, @response.body
    users(:admin).widgets.reload
    refute_includes users(:admin).widget_ids, widget.id
  end

  test "#destroy returns forbidden for other user's widget" do
    other_user = FactoryBot.create(:user, :with_widget)
    widget = other_user.widgets.first
    delete :destroy, params: { :id => widget.id, :format => 'json' }, session: set_session_user
    assert_response :forbidden
    assert_equal widget.id.to_s, @response.body
    assert_includes other_user.widgets.reload, widget
  end

  test "#reset_to_default resets user's widgets" do
    Dashboard::Manager.expects(:reset_user_to_default).with(users(:admin))
    put :reset_default, session: set_session_user
    assert_redirected_to root_path
  end

  test "#save_positions updates each widget" do
    widget = FactoryBot.create(:widget, :user => users(:admin))
    params = {
      widget.id.to_s => {:col => '4', :row => '3', :sizex => '8', :sizey => '1'},
    }
    post :save_positions, params: { :widgets => params, :format => 'json' }, session: set_session_user
    assert_response :success
    widget.reload
    assert_equal 4, widget.col
    assert_equal 3, widget.row
  end
end
