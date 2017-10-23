require 'test_helper'

class WidgetTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
  end

  test 'new user should have default widgets' do
    assert_equal Dashboard::Manager.default_widgets.count, FactoryBot.create(:user).widgets.count
  end

  test 'reset to default should add default widgets to user' do
    @user.widgets = []
    assert_difference('@user.widgets.count', Dashboard::Manager.default_widgets.count) do
      Dashboard::Manager.reset_user_to_default(@user)
    end
  end

  test 'adding widget to user should fill in default values for missing fields' do
    widget_hash = { :template => Dashboard::Manager.default_widgets[0][:template],
                    :name => Dashboard::Manager.default_widgets[0][:name] }
    assert_difference('@user.widgets.count', 1) do
      Dashboard::Manager.add_widget_to_user(@user, widget_hash)
    end
    widget = @user.widgets.last
    assert_equal 4, widget.sizex
    assert_equal 1, widget.sizey
    assert_equal 1, widget.col
    assert_equal 1, widget.row
    assert widget.data.blank?
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
