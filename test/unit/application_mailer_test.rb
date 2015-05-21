require 'test_helper'

class ApplicationMailerTest < ActiveSupport::TestCase
  setup { ActionMailer::Base.deliveries = [] }

  def mail
    ApplicationMailer.mail(:to => 'nobody@example.com', :subject => 'Danger, Will Robinson!') do |mail|
      format.text "This is a test mail."
    end.deliver
    ActionMailer::Base.deliveries.last
  end

  test "foreman server header is set" do
    assert_equal mail.header['X-Foreman-Server'].to_s, 'foreman.some.host.fqdn'
  end

  test "foreman subject prefix is attached" do
    Setting[:email_subject_prefix] = '[foreman-production]'
    assert_match /^\[foreman-production\]/, mail.subject
  end
end
