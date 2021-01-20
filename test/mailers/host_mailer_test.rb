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

  test 'error_state sends mail with correct headers' do
    report = FactoryBot.create(:report)
    user = FactoryBot.create(:user, :with_mail)
    mail = HostMailer.error_state(report, :user => user).deliver_now
    assert_includes mail.from, Setting["email_reply_address"]
    assert_includes mail.to, user.mail
    assert_includes mail.subject, report.host.name
    assert mail.body.present?
  end
end
