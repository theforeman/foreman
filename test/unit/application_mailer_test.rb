require 'test_helper'

class ApplicationMailerTest < ActiveSupport::TestCase
  setup { ActionMailer::Base.deliveries = [] }

  class TestMailer < ::ApplicationMailer
    def test
      mail(:to => 'nobody@example.com', :subject => 'Danger, Will Robinson!') do |format|
        format.text { render plain: "This is a test mail." }
      end
    end
  end

  def mail
    TestMailer.test.deliver
    ActionMailer::Base.deliveries.last
  end

  test 'foreman server header is set' do
    assert_equal mail.header['X-Foreman-Server'].to_s, 'foreman.some.host.fqdn'
  end

  test 'foreman subject prefix is attached' do
    Setting[:email_subject_prefix] = '[foreman-production]'
    assert_match /^\[foreman-production\]/, mail.subject
  end

  # The ActionMailer default is only evaluated at initialization so changes
  # were only registered after a restart.  The from address is now a lambda.
  test 'reply address evalulated at send time' do
    new_from = 'foreman@widgets.example.com'
    Setting[:email_reply_address] = new_from
    assert_equal mail.from.first, new_from
  end
end
