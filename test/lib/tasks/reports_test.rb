require 'test_helper'
require 'rake'

class ReportsTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/reports'
    Rake::Task.define_task(:environment)
    Rake::Task['reports:daily'].reenable

    as_admin do
      ActionMailer::Base.deliveries = []
      @owner = FactoryGirl.create(:user, :admin, :with_mail)
      @owner.mail_notifications << MailNotification[:puppet_summary]
      @owner.user_mail_notifications.all.each { |notification| notification.update_attribute(:interval, 'Daily') }
      @host = FactoryGirl.create(:host, :owner => @owner)
    end
  end

  test 'reports:daily sends mail' do
    Rake.application.invoke_task 'reports:daily'
    mail = ActionMailer::Base.deliveries.detect { |delivery| delivery.subject =~ /Puppet Summary/ }
    assert mail
    assert_match /Summary from/, mail.body.encoded
  end

  test 'reports:daily shows a recent report' do
    as_admin do
      report = read_json_fixture('report-errors.json')
      report["host"] = @host.name

      ConfigReportImporter.import report
      ConfigReport.update_all(:reported_at => 1.minute.ago)
    end

    Rake.application.invoke_task 'reports:daily'
    mail = ActionMailer::Base.deliveries.detect { |delivery| delivery.subject =~ /Puppet Summary/ }
    assert mail
    assert_match /#{@host.name}/, mail.body.encoded
  end
end
