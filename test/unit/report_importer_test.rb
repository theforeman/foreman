require 'test_helper'

class ReportImporterTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries = []
  end

  test 'json_fixture_loader' do
    assert_kind_of Hash, read_json_fixture('reports/empty.json')
  end

  test 'it should import reports with no metrics' do
    r = TestReportImporter.import(read_json_fixture('reports/empty.json'))
    assert r
    assert_equal({}, r.metrics)
  end

  test 'it should import reports where logs is nil' do
    r = TestReportImporter.import read_json_fixture('reports/no-logs.json')
    assert_empty r.logs
  end

  context 'config error state notification' do
    setup do
      @user = as_admin { FactoryBot.create(:user, :admin, :with_mail) }
      @user.mail_notifications << ConfigManagementError.first
      @host = FactoryBot.build(:host)
    end

    test "when a user is subscribed to all hosts notification,  a mail should be sent on error" do
      @user.user_mail_notifications.all.each { |notification| notification.update_attribute(:interval, 'Subscribe to all hosts') }
      assert_difference 'ActionMailer::Base.deliveries.size' do
        report = read_json_fixture('reports/errors.json')
        report["host"] = @host.name
        ConfigReportImporter.import report
      end
    end

    test "when a user is subscribed to his hosts, a mail shouldn't be sent on other host error" do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        report = read_json_fixture('reports/errors.json')
        report["host"] = @host.name
        ConfigReportImporter.import report
      end
    end
  end

  context 'with user owner' do
    setup do
      @owner = as_admin { FactoryBot.create(:user, :admin, :with_mail) }
      @host = FactoryBot.create(:host, :owner => @owner)
    end

    # Only ConfigReportImporter is set to send config error states
    test 'when owner is subscribed to notification, a mail should be sent on error' do
      @owner.mail_notifications << ConfigManagementError.first
      @owner.user_mail_notifications.all.each { |notification| notification.update_attribute(:interval, 'Subscribe to my hosts') }
      assert_difference 'ActionMailer::Base.deliveries.size' do
        report = read_json_fixture('reports/errors.json')
        report["host"] = @host.name
        ConfigReportImporter.import report
      end
    end

    test 'when owner is not subscribed to notifications, no mail should be sent on error' do
      @owner.mail_notifications = []
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        report = read_json_fixture('reports/errors.json')
        report["host"] = @host.name
        TestReportImporter.import report
      end
    end
  end

  test 'when a host has no owner, no mail should be sent on error' do
    host = FactoryBot.build(:host, :owner => nil)
    report = read_json_fixture('reports/errors.json')
    report["host"] = host.name
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      TestReportImporter.import report
    end
  end

  # Only ConfigReportImporter is set to send config error states
  test 'when usergroup owner is subscribed to notification, a mail should be sent to all users on error' do
    ug = FactoryBot.create(:usergroup, :users => FactoryBot.create_pair(:user, :with_mail))
    Usergroup.any_instance.expects(:recipients_for).with(:config_error_state).returns(ug.users)
    host = FactoryBot.create(:host, :owner => ug)
    report = read_json_fixture('reports/errors.json')
    report["host"] = host.name
    ConfigReportImporter.import report
    assert_equal ug.users.map { |u| u.mail }, ActionMailer::Base.deliveries.map { |d| d.to }.flatten
  end

  test 'if report has no error, no mail should be sent' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      TestReportImporter.import read_json_fixture('reports/applied.json')
    end
  end

  test 'when a host does not exist, it builds a new one' do
    report = read_json_fixture('reports/errors.json')
    report["host"] = 'SOMETHING'
    reporter = ReportImporter.new(report)
    host = reporter.send(:host)
    assert_equal 'something', host.name
  end

  test 'hostname is matched downcased' do
    db_host = FactoryBot.create(:host)
    report = read_json_fixture('reports/errors.json')
    report["host"] = db_host.name.upcase
    reporter = ReportImporter.new(report)
    host = reporter.send(:host)
    assert_equal host, db_host
  end

  test 'it should refresh all statuses' do
    host = FactoryBot.build(:host)
    report = read_json_fixture('reports/applied.json')
    report["host"] = host.name
    reporter = TestReportImporter.new(report)
    reporter.send(:host).expects(:refresh_statuses).with(HostStatus.status_registry)
    reporter.import
  end

  test 'it should refresh zero statuses' do
    host = FactoryBot.build(:host)
    report = read_json_fixture('reports/applied.json')
    report["host"] = host.name
    reporter = TestNoStatusUpdateReportImporter.new(report)
    reporter.send(:host).expects(:refresh_statuses).with([])
    reporter.import
  end

  describe 'Report scanning' do
    let(:report_scanner) { stub_everything('TestReportScanner', :identify_origin => 'TestOrigin') }
    let(:report) { read_json_fixture('reports/empty.json') }

    describe '#add_reporter_specific_data' do
      let(:importer) { TestReportImporter.new(report) }
      setup do
        importer.stubs(:report_scanners).returns([report_scanner])
        importer.send(:create_report_and_logs)
      end

      it 'calls add_reporter_specific_data with the report on scanner' do
        report_scanner.expects(:add_reporter_data)
        importer.send(:add_reporter_specific_data)
        assert_equal importer.report.origin, 'TestOrigin'
      end
    end
  end
end

class TestReportImporter < ReportImporter
  def report_status
    0
  end

  def report_name_class
    Report
  end
end

class TestNoStatusUpdateReportImporter < TestReportImporter
  def statuses_for_refresh
    []
  end
end
