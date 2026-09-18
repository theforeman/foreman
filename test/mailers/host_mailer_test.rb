require 'test_helper'

class HostMailerTest < ActionMailer::TestCase
  def setup
    disable_orchestration
    @host = FactoryBot.create(:host)
    as_admin do
      @host.last_report = Time.at(0).utc
      @host.save(:validate => false)
    end

    User.current = users :admin

    Setting[:foreman_url] = "http://dummy.theforeman.org:3000/hosts/:id"

    @options = {}
    @options[:user] = User.current.id

    ActionMailer::Base.deliveries = []
  end

  test "mail should have the specified recipient" do
    assert HostMailer.summary(@options).deliver_now.to.include?("admin@someware.com")
  end

  test "mail should have a subject" do
    assert !HostMailer.summary(@options).deliver_now.subject.empty?
  end

  test "mail should have a body" do
    assert !HostMailer.summary(@options).deliver_now.body.empty?
  end

  test "mail should report at least one host" do
    assert HostMailer.summary(@options).deliver_now.body.include?(@host.name)
  end

  test "mail should report disabled hosts" do
    @host.enabled = false
    @host.save
    assert HostMailer.summary(@options).deliver_now.body.include?(@host.name)
  end

  test "skips configuration summary with an empty body when the user opts out" do
    nothing_to_report
    @options[:skip_if_empty] = true

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      HostMailer.summary(@options).deliver_now
    end
  end

  test "delivers configuration summary with an empty body when the user opts in" do
    nothing_to_report
    @options[:skip_if_empty] = false

    assert_difference 'ActionMailer::Base.deliveries.size' do
      HostMailer.summary(@options).deliver_now
    end
  end

  test "delivers configuration summary with eventful reports when the user opts out of empty ones" do
    nothing_to_report
    # status 1 is a single 'applied' resource, which makes the host eventful
    FactoryBot.create(:config_report, host: @host, status: 1)
    @options[:skip_if_empty] = true

    assert_difference 'ActionMailer::Base.deliveries.size' do
      HostMailer.summary(@options).deliver_now
    end
  end

  test "delivers configuration summary with out of sync hosts when the user opts out of empty ones" do
    nothing_to_report
    as_admin { @host.update_columns(last_report: Time.at(0).utc) }
    @options[:skip_if_empty] = true

    assert_difference 'ActionMailer::Base.deliveries.size' do
      HostMailer.summary(@options).deliver_now
    end
  end

  test "delivers configuration summary with alert disabled hosts when the user opts out of empty ones" do
    nothing_to_report
    as_admin { @host.update_columns(enabled: false) }
    @options[:skip_if_empty] = true

    assert_difference 'ActionMailer::Base.deliveries.size' do
      HostMailer.summary(@options).deliver_now
    end
  end

  test 'error_state sends mail with correct headers' do
    report = FactoryBot.create(:report)
    user = FactoryBot.create(:user, :with_mail)
    mail = HostMailer.error_state(report, :user => user).deliver_now
    assert_includes mail.from, Setting["email_reply_address"]
    assert_includes mail.to, user.mail
    assert_includes mail.subject, report.host.name
    assert mail.body.present?
  end

  private

  # leaves the summary with no eventful, out of sync or alert disabled hosts,
  # i.e. with an empty body
  def nothing_to_report
    as_admin do
      Report.unscoped.delete_all
      Host::Managed.unscoped.update_all(last_report: Time.now.utc, enabled: true)
    end
  end
end
