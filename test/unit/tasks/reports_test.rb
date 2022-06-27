require 'test_helper'
require 'rake'

class ReportsTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/reports'
    Rake::Task.define_task(:environment)
    Rake::Task.define_task(:"dynflow:client")
    Rake::Task['reports:daily'].reenable

    as_admin do
      ActionMailer::Base.deliveries = []
      @owner = FactoryBot.create(:user, :admin, :with_mail, :mail_enabled => true)
      @owner.mail_notifications << MailNotification[:config_summary]
      @owner.user_mail_notifications.all.each { |notification| notification.update_attribute(:interval, 'Daily') }
      @host = FactoryBot.create(:host, :owner => @owner)
    end
  end

  test 'reports:daily sends mail' do
    Rake.application.invoke_task 'reports:daily'
    mail = ActionMailer::Base.deliveries.detect { |delivery| delivery.subject =~ /Configuration Management Summary/ }
    assert mail
    assert_match /Summary from/, mail.body.encoded
  end

  test 'reports:daily works also for admins not assigned to any organization/location' do
    @owner.organizations = []
    @owner.locations = []
    User.current, saved_user = nil, User.current
    Rake.application.invoke_task 'reports:daily'
    mail = ActionMailer::Base.deliveries.detect { |delivery| delivery.subject =~ /Configuration Management Summary/ }
    User.current = saved_user
    assert mail
    assert_match /Summary from/, mail.body.encoded
  end

  test 'reports:daily shows a recent report' do
    as_admin do
      report = read_json_fixture('reports/errors.json')
      report["host"] = @host.name

      ConfigReportImporter.import report
      ConfigReport.update_all(:reported_at => 1.minute.ago)
    end

    Rake.application.invoke_task 'reports:daily'
    mail = ActionMailer::Base.deliveries.detect { |delivery| delivery.subject =~ /Configuration Management Summary/ }
    assert mail
    assert_match /#{@host.name}/, mail.body.encoded
  end
end
