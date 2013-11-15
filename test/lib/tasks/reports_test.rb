require 'test_helper'
require 'rake'

class ReportsTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/reports'
    Rake::Task.define_task(:environment)
    Rake::Task['reports:summarize'].reenable
  end

  test 'reports:summarize sends mail' do
    Rake.application.invoke_task 'reports:summarize'
    mail = ActionMailer::Base.deliveries.last
    assert mail
    assert_match /Summary Puppet report from Foreman/, mail.subject
    assert_match /Summary from/, mail.body.encoded
  end

  test 'reports:summarize shows a recent report' do
    as_admin do
      ReportImporter.import read_json_fixture('report-errors.json')
      Report.update_all(:reported_at => 1.minute.ago)
    end

    Rake.application.invoke_task 'reports:summarize'
    mail = ActionMailer::Base.deliveries.last
    assert mail
    assert_match /my.sol.client.com/, mail.body.encoded
  end
end
