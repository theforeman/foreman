require 'test_helper'

class ApplicationMailerTest < ActiveSupport::TestCase

  setup do
    ActionMailer::Base.deliveries = []
    Setting[:email_subject_prefix] = '[foreman-production]'

    ApplicationMailer.mail(:to => 'nobody@example.com', :subject => 'Danger, Will Robinson!') do |mail|
      format.text "This is a test mail."
    end.deliver

    @mail = ActionMailer::Base.deliveries.first
  end

  test "foreman server header is set" do
    assert_equal @mail.header['X-Foreman-Server'].to_s, 'foreman.some.host.fqdn'
  end

  test "foreman subject prefix is attached" do
    assert_match /^\[foreman-production\]/, @mail.subject
  end
end
