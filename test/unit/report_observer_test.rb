require 'test_helper'

class ReportObserverTest < ActiveSupport::TestCase
  def setup
    User.current = User.find_by_login "admin"

    # Email recepient
    SETTINGS[:administrator] = "admin@example.com"

    # Host and Report creation
    h = Host.create  :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                      :domain => Domain.find_or_create_by_name("company.com"),
                      :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                      :architecture => Architecture.find_or_create_by_name("i386"),
                      :environment => Environment.find_or_create_by_name("envy"),
                      :disk => "empty partition"
    h.update_attribute :owner, User.first if SETTINGS[:login]

    @report = Report.new :host => h, :reported_at => Date.today
  end

  test "when notification fails, if report has an error a mail to admin should be sent" do
    SETTINGS[:failed_report_email_notification] = true
    assert_difference 'ActionMailer::Base.deliveries.size' do
      @report.status = 16781381 # Error status.
      @report.save!
      @report
    end
  end

  test "when notification doesn't fails, if report has an error, no mail should be sent" do
    SETTINGS[:failed_report_email_notification] = false
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      @report.status = 16781381 # Error status.
      @report.save!
    end
  end

  test "if report has no error, no mail should be sent" do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      @report.status = 79
      @report.save!
    end
  end
end
