require 'test_helper'

class ReportImporterTest < ActiveSupport::TestCase

  def setup
    User.current = users :admin
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

  test 'when notification is set to true, if report has an error, a mail to admin should be sent' do
    setup_for_email_reporting
    Setting[:failed_report_email_notification] = true
    assert_difference 'ActionMailer::Base.deliveries.size' do
      ReportImporter.import read_json_fixture('report-errors.json')
    end
  end

  test 'when notification is set to false, if the report has an error, no mail should be sent' do
    setup_for_email_reporting
    Setting[:failed_report_email_notification] = false
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      ReportImporter.import read_json_fixture('report-errors.json')
    end
  end

  test 'if report has no error, no mail should be sent' do
    setup_for_email_reporting
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      ReportImporter.import read_json_fixture('report-applied.json')
    end
  end

  private

  def setup_for_email_reporting
    # Email recipient
    Setting[:administrator] = 'admin@example.com'
    Setting[:failed_report_email_notification] = true
  end

end
