require 'test_helper'

class HostMailerTest < ActionMailer::TestCase
  def setup
    disable_orchestration
    @env = environments(:production)
    @host = FactoryGirl.create(:host, :environment => @env)
    as_admin do
      @host.last_report = Time.at(0)
      @host.save(:validate => false)
      @env.hosts << @host
      @env.save
    end

    User.current = users :admin

    Setting[:foreman_url] = "http://localhost:3000/hosts/:id"

    @options = {}
    @options[:env] = @env
    @options[:user] = User.current.id

    # HostMailer relies on .size, and Rails looks to the counter_caches
    # if they exist.  Since fixtures don't populate the counter_caches,
    # we do it here:
    Environment.reset_counters(@env, :hosts)
    @env.reload

    ActionMailer::Base.deliveries = []
  end

  test "mail should have the specified recipient" do
    assert HostMailer.summary(@options).deliver.to.include?("admin@someware.com")
  end

  test "mail should have a subject" do
    assert !HostMailer.summary(@options).deliver.subject.empty?
  end

  test "mail should have a body" do
    assert !HostMailer.summary(@options).deliver.body.empty?
  end

  test "mail should report at least one host" do
    assert HostMailer.summary(@options).deliver.body.include?(@host.name)
  end

  test "mail should report disabled hosts" do
    @host.enabled = false
    @host.save
    assert HostMailer.summary(@options).deliver.body.include?(@host.name)
  end

  test 'error_state sends mail with correct headers' do
    report = FactoryGirl.create(:report)
    user = FactoryGirl.create(:user, :with_mail)
    mail = HostMailer.error_state(report, :user => user).deliver
    assert_includes mail.from, Setting["email_reply_address"]
    assert_includes mail.to, user.mail
    assert_includes mail.subject, report.host.name
    assert_present mail.body
  end
end
