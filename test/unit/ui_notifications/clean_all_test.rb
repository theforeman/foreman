require 'test_helper'

class CleanAllTest < ActiveSupport::TestCase
  test "clean should remove all notifications including non-expired ones" do
    blueprint = create_blueprint(5.minutes)
    blueprint2 = create_blueprint(-5.minutes)
    create_notification(blueprint)
    create_notification(blueprint2)
    assert_equal 2, Notification.all.size
    cleaner = UINotifications::CleanAll.new
    assert_equal 2, cleaner.clean!.deleted_count
    assert_equal 0, Notification.all.size
  end

  test "clean by blueprint should remove only notifications belonging to that blueprint" do
    blueprint = create_blueprint(5.minutes)
    blueprint2 = create_blueprint(5.minutes)
    create_notification(blueprint)
    create_notification(blueprint)
    create_notification(blueprint2)
    assert_equal 3, Notification.all.size
    cleaner = UINotifications::CleanAll.new(blueprint: blueprint.name)
    assert_equal 2, cleaner.clean!.deleted_count
    assert_equal 1, Notification.all.size
    assert_equal blueprint2, Notification.first.notification_blueprint
  end

  test "clean by blueprint that does not exist should remove no notifications" do
    blueprint = create_blueprint(5.minutes)
    create_notification(blueprint)
    assert_equal 1, Notification.all.size
    cleaner = UINotifications::CleanAll.new(blueprint: 'nonexistent_blueprint')
    assert_equal 0, cleaner.clean!.deleted_count
    assert_equal 1, Notification.all.size
  end

  test "deleted_count raises before clean! is called" do
    cleaner = UINotifications::CleanAll.new
    assert_raise RuntimeError do
      cleaner.deleted_count
    end
  end

  private

  def create_notification(blueprint)
    FactoryBot.create(:notification,
      :audience => Notification::AUDIENCE_ADMIN,
      :notification_blueprint => blueprint)
  end

  def create_blueprint(expired_time)
    blueprint = FactoryBot.build(:notification_blueprint, :expires_in => expired_time)
    blueprint.save(:validate => false)
    blueprint
  end
end
