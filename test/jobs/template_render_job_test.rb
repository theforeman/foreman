require 'test_helper'

class TemplateRenderJobTest < ActiveJob::TestCase
  describe 'processing' do
    def render_job(composer_params)
      job = TemplateRenderJob.new(composer_params, user_id: users(:admin).id)
      job.provider_job_id = 'UNIQUE-PROVIDER-ID'
      job
    end

    it 'render report and stores it' do
      composer = MiniTest::Mock.new
      composer.expect('render', 'result')
      composer.expect('send_mail?', false)
      ReportComposer.expects('new').with('foo' => 'bar', 'gzip' => false).returns(composer)
      StoredValue.expects('write').with('UNIQUE-PROVIDER-ID', 'result', has_key(:expire_at))
      render_job({'foo' => 'bar'}).perform_now
      assert composer.verify
    end

    it 'render report and delivers it to mail' do
      mailer = mock('mailer')
      mailer.expects('deliver_now')
      composer_params = { 'foo' => 'bar', 'send_mail' => true, 'mail_to' => 'test@example.org', 'gzip' => true }

      ReportComposer.any_instance.expects('render').returns('result')
      ReportMailer.expects('report').with(composer_params, 'result', has_entries(start: is_a(Time), end: is_a(Time))).returns(mailer)
      render_job(composer_params).perform_now
    end
  end

  describe '#humanized_name' do
    let(:template) { FactoryBot.create(:report_template, :organizations => [taxonomies(:organization1)], :locations => [taxonomies(:location1)]) }
    before do
      @job = TemplateRenderJob.new({'template_id' => template.id, 'foo' => 'bar'}, user_id: users(:admin).id)
      @job.provider_job_id = 'UNIQUE-PROVIDER-ID'
    end

    it 'returns template name' do
      assert_equal @job.humanized_name, "Render report #{template.name}"
    end
  end
end
