require 'test_helper'

class WidgetTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end

  test 'new user should have no widgets' do
    assert_blank(@user.widgets)
  end

  test 'reset to default should add default widgets to user' do
    assert_difference('@user.widgets.count', Dashboard::Manager.default_widgets.count) do
      Dashboard::Manager.reset_user_to_default(@user)
    end
  end

  test 'adding widget to user should fill in default values for missing fields' do
    widget_hash = { :template => Dashboard::Manager.default_widgets[0][:template],
                    :name => Dashboard::Manager.default_widgets[0][:name] }
    assert Dashboard::Manager.add_widget_to_user(@user, widget_hash)
    assert_equal @user.widgets.count, 1
    widget = @user.widgets.first
    assert_equal widget.sizex, 4
    assert_equal widget.sizey, 1
    assert_equal widget.col, 1
    assert_equal widget.row, 1
    refute widget.hide
    assert_blank widget.data
    assert_equal widget.user_id, @user.id
  end

  test 'adding widget with unallowed template raises exception' do
    widget_hash = { :template => 'malicious_template',
                    :name => 'malicious template name'}
    assert_raises ::Foreman::Exception do
      Dashboard::Manager.add_widget_to_user(@user, widget_hash)
    end
  end
end
