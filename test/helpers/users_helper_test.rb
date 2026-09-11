require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  include UsersHelper

  def setup
    @user = FactoryBot.build(:user)
  end

  # Query builders are supplied by whoever owns the notification, so plugins
  # render their own markup here. Some of them position it against the form and
  # draw their own connector, which anything added around or onto them would
  # break, so the rows they return have to come back out untouched.
  test 'leaves a query builder from a plugin untouched' do
    plugin_markup = '<div id="plugin_query_builder" style="left: 20%">days</div>'.html_safe
    stubs(:mail_notification_query_builder).returns(plugin_markup)

    notification = FactoryBot.build(:mail_notification, :queryable, :skippable)
    rows = option_rows_for(notification)

    assert_equal 2, rows.size
    assert_equal 'plugin_query_builder', rows.first['id']
    assert_nil rows.first['class']
    assert_equal 'left: 20%', rows.first['style']
  end

  test 'joins the skip if empty checkbox to the connector' do
    rows = option_rows_for(FactoryBot.build(:mail_notification, :skippable))

    assert_equal 1, rows.size
    assert_includes rows.first['class'], 'mail_notification_option'
    assert_includes rows.first.to_html, 'skip_if_empty'
  end

  test 'renders nothing for a notification with no options' do
    notification = FactoryBot.build(:mail_notification)
    refute notification.queryable?
    refute notification.skippable?

    assert_nil mail_notification_options(notification, form_builder_for(notification))
  end

  private

  def option_rows_for(notification)
    html = mail_notification_options(notification, form_builder_for(notification))
    container = Nokogiri::HTML.fragment(html).at_css('div.mail_notification_options')
    assert_not_nil container
    container.element_children
  end

  def form_builder_for(notification)
    user_mail_notification = UserMailNotification.new(user: @user, mail_notification: notification)
    ActionView::Helpers::FormBuilder.new(:user_mail_notification, user_mail_notification, view, {})
  end
end
