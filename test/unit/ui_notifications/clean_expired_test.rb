require 'test_helper'

class CleanExpiredTest < ActiveSupport::TestCase
  test "clean should remove all expired notifications" do
    blueprint = create_blueprint(-5.minutes, false)
    blueprint2 = create_blueprint(5.minutes, true)
    create_notification(blueprint)
    create_notification(blueprint)
    create_notification(blueprint2)
    notifications = Notification.all
    cleaner = UINotifications::CleanExpired.new
    assert_equal 3, notifications.length
    assert_equal 2, cleaner.clean!.deleted_count
  end

  test "clean with a given time should remove all expired notification until this time" do
    blueprint = create_blueprint(-5.minutes, false)
    blueprint2 = create_blueprint(-1.minute, false)
    create_notification(blueprint)
    create_notification(blueprint2)
    assert_equal 2, Notification.all.length
    time = Time.zone.now - 3.minutes
    cleaner = UINotifications::CleanExpired.new(expired_at: time.to_s)
    assert_equal 1, cleaner.clean!.deleted_count
  end

  test "clean with a given group name should remove only expired notifications which belong to a blueprint group" do
    blueprint = create_blueprint(-5.minutes, false)
    blueprint2 = create_blueprint(-5.minutes, false)
    create_notification(blueprint)
    create_notification(blueprint2)
    cleaner = UINotifications::CleanExpired.new(group: blueprint.group)
    assert_equal 2, Notification.all.size
    assert_equal 1, cleaner.clean!.deleted_count
    assert_equal blueprint2.group, Notification.first.notification_blueprint.group
  end

  test "clean with a given group and time should remove associated time-expired notifications" do
    blueprint = create_blueprint(-5.minutes, false)
    create_notification(blueprint)
    time = Time.zone.now - 6.minutes
    cleaner = UINotifications::CleanExpired.new(expired_at: time.to_s, group: blueprint.group)
    assert_equal 0, cleaner.clean!.deleted_count
    time = Time.zone.now - 3.minutes
    cleaner = UINotifications::CleanExpired.new(expired_at: time.to_s, group: blueprint.group)
    assert_equal 1, cleaner.clean!.deleted_count
  end

  test "clean by blueprint should remove only expired notifications which belong to a blueprint" do
    blueprint = create_blueprint(-5.minutes, false)
    blueprint2 = create_blueprint(-5.minutes, false)
    create_notification(blueprint)
    create_notification(blueprint2)
    assert_equal 2, Notification.all.size
    cleaner = UINotifications::CleanExpired.new(blueprint: blueprint.name)
    assert_equal 1, cleaner.clean!.deleted_count
    assert_equal blueprint2, Notification.first.notification_blueprint
  end

  test "clean with a given blueprint name and time should remove only associated time-expired notifications" do
    blueprint = create_blueprint(-5.minutes, false)
    create_notification(blueprint)
    time = Time.zone.now - 6.minutes
    cleaner = UINotifications::CleanExpired.new(expired_at: time.to_s, blueprint: blueprint.name)
    assert_equal 0, cleaner.clean!.deleted_count
    time = Time.zone.now - 3.minutes
    cleaner = UINotifications::CleanExpired.new(expired_at: time.to_s, blueprint: blueprint.name)
    assert_equal 1, cleaner.clean!.deleted_count
  end

  test "clean with a given time should raise an error if time is in the future" do
    blueprint = create_blueprint(-5.minutes, false)
    blueprint2 = create_blueprint(-1.minute, false)
    create_notification(blueprint)
    create_notification(blueprint2)
    time = Time.zone.now + 3.minutes
    assert_raise Foreman::Exception do
      assert_equal UINotifications::CleanExpired.new(expired_at: time.to_s).clean!
    end
  end

  test "clean with a given unparsed time string should raise an error" do
    assert_raise Foreman::Exception do
      assert_equal UINotifications::CleanExpired.new(expired_at: 'unparsed_time').clean!
    end
  end

  private

  def create_notification(blueprint)
    FactoryBot.create(:notification,
      :audience => Notification::AUDIENCE_ADMIN,
      :notification_blueprint => blueprint)
  end

  def create_blueprint(expired_time, validate = true)
    blueprint = FactoryBot.build(
      :notification_blueprint,
      :expires_in => expired_time
    )
    blueprint.save(:validate => validate)
    blueprint
  end
end
