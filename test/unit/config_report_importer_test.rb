require 'test_helper'

class ConfigReportImporterTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries = []
  end

  context 'with user owner' do
    setup do
      @owner = as_admin { FactoryGirl.create(:user, :admin, :with_mail) }
      @host = FactoryGirl.create(:host, :owner => @owner)
    end

    test 'when owner is subscribed to notification, a mail should be sent on error' do
      @owner.mail_notifications << MailNotification[:puppet_error_state]
      assert_difference 'ActionMailer::Base.deliveries.size' do
        report = read_json_fixture('report-errors.json')
        report["host"] = @host.name
        ConfigReportImporter.import report
      end
    end

    test 'when owner is not subscribed to notifications, no mail should be sent on error' do
      @owner.mail_notifications = []
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        report = read_json_fixture('report-errors.json')
        report["host"] = @host.name
        ConfigReportImporter.import report
      end
    end
  end

  test 'when a host has no owner, no mail should be sent on error' do
    host = FactoryGirl.create(:host, :owner => nil)
    report = read_json_fixture('report-errors.json')
    report["host"] = host.name
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      ConfigReportImporter.import report
    end
  end

  test 'when usergroup owner is subscribed to notification, a mail should be sent to all users on error' do
    ug = FactoryGirl.create(:usergroup, :users => FactoryGirl.create_pair(:user, :with_mail))
    Usergroup.any_instance.expects(:recipients_for).with(:puppet_error_state).returns(ug.users)
    host = FactoryGirl.create(:host, :owner => ug)
    report = read_json_fixture('report-errors.json')
    report["host"] = host.name
    ConfigReportImporter.import report
    assert_equal ug.users.map { |u| u.mail }, ActionMailer::Base.deliveries.map { |d| d.to }.flatten
  end

  test 'if report has no error, no mail should be sent' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      ConfigReportImporter.import read_json_fixture('report-applied.json')
    end
  end
end
