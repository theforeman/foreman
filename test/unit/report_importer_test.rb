require 'test_helper'

class ReportImporterTest < ActiveSupport::TestCase

  def setup
    User.current = users :admin
    ActionMailer::Base.deliveries = []
    @owner = FactoryGirl.create(:user, :admin, :with_mail)
    @host = FactoryGirl.create(:host, :owner => @owner)
  end

  def teardown
    User.current = nil
  end

  test 'json_fixture_loader' do
    assert_kind_of Hash, read_json_fixture('report-empty.json')
  end

  test 'it should import reports with no metrics' do
    r = ReportImporter.import(read_json_fixture('report-empty.json'))
    assert r
    assert_equal({}, r.metrics)
  end

  test 'it should import reports where logs is nil' do
    r = Report.import read_json_fixture('report-no-logs.json')
    assert_empty r.logs
  end

  test 'when owner is subscribed to notification, a mail should be sent on error' do
    @owner.mail_notifications << MailNotification[:puppet_error_state]
    assert_difference 'ActionMailer::Base.deliveries.size' do
      report = read_json_fixture('report-errors.json')
      report["host"] = @host.name
      ReportImporter.import report
    end
  end

  test 'when owner is not subscribed to notifications, no mail should be sent on error' do
    @owner.mail_notifications = []
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      report = read_json_fixture('report-errors.json')
      report["host"] = @host.name
      ReportImporter.import report
    end
  end

  test 'if report has no error, no mail should be sent' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      ReportImporter.import read_json_fixture('report-applied.json')
    end
  end

end
