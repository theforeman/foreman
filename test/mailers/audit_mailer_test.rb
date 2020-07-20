require 'test_helper'
require 'cgi'

class AuditMailerTest < ActionMailer::TestCase
  def setup
    disable_orchestration
    # Add 'update' action to audits
    @audit = FactoryBot.create(:audit)
    as_admin do
      # Add 'create' action to audits
      @host = FactoryBot.create(:host)
    end
    @options = {}
    @options[:env] = @env
    @options[:user] = users(:admin).id
  end

  test 'Audit mail subject should be Audit summary' do
    assert_not_nil(AuditMailer.summary(@options).deliver_now.subject)
    assert_includes(AuditMailer.summary(@options).deliver_now.subject, _("Audit summary"))
  end

  test 'Audit mail should support two mime-types' do
    # text is first, html second
    assert_equal(AuditMailer.summary(@options).deliver_now.body.parts.length, 2)
    assert_equal(AuditMailer.summary(@options).deliver_now.body.parts.first.content_type, "text/plain; charset=UTF-8")
    assert_equal(AuditMailer.summary(@options).deliver_now.body.parts.last.content_type, "text/html; charset=UTF-8")
    assert_includes(AuditMailer.summary(@options).deliver_now.body.parts.last.body, "<body")
  end

  test 'Audit mail should display query results' do
    @options[:query] = "action != #{@audit.action}"
    refute_includes(AuditMailer.summary(@options).deliver_now.body.parts.first.body, "#{@audit.action}d")
  end

  test 'Audit mail should display total count of audits' do
    @options[:time] = '1973-01-13 00:12'
    count = Audit.all.count
    number_of = (Setting[:entries_per_page] > count) ? count : Setting[:entries_per_page]
    assert_includes(AuditMailer.summary(@options).deliver_now.body.parts.first.body, "Displaying #{number_of} of #{count} audits")
  end

  test 'Audit html mail should include link to query' do
    @options[:time] = '1970-01-01'
    @options[:query] = 'action = create'
    query_should_be = CGI.escape(%(#{@options[:query]} and time >= "#{@options[:time]}"))
    assert_includes(AuditMailer.summary(@options).deliver_now.body.parts.last.body, query_should_be)
  end

  test 'Audit html mail should include correct id query' do
    @options[:query] = 'id = 21'
    query_should_be = CGI.escape(@options[:query])
    assert_includes(AuditMailer.summary(@options).deliver_now.body.parts.last.body, query_should_be)
  end

  test "Audit template change should not crash" do
    template = FactoryBot.create(:provisioning_template, :template => 'aaaa', :snippet => true)
    template.update!(:template => 'bbbbbb')
    audit = template.reload.audits.last
    @options[:query] = "id = #{audit.id}"
    assert_includes(AuditMailer.summary(@options).deliver_now.body.parts.last.body, 'Template content changed')
  end
end
