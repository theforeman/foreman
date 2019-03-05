require 'test_helper'

class TemplateRenderJobTest < ActiveJob::TestCase
  describe 'processing' do
    before do
      @job = TemplateRenderJob.new({'foo' => 'bar'}, user_id: users(:admin).id)
      @job.provider_job_id = 'UNIQUE-PROVIDER-ID'
    end

    it 'calls ReportComposer to render and store report' do
      composer = MiniTest::Mock.new
      composer.expect('render_to_store', nil, ['UNIQUE-PROVIDER-ID'])
      ReportComposer.expects('new').with('foo' => 'bar', 'gzip' => false).returns(composer)
      @job.perform_now
      assert composer.verify
    end
  end

  describe '#humanized_name' do
    let(:template) { FactoryBot.create(:report_template, :organizations => [ taxonomies(:organization1) ], :locations => [ taxonomies(:location1) ]) }
    before do
      @job = TemplateRenderJob.new({'template_id' => template.id, 'foo' => 'bar'}, user_id: users(:admin).id)
      @job.provider_job_id = 'UNIQUE-PROVIDER-ID'
    end

    it 'returns template name' do
      assert_equal @job.humanized_name, "Render report #{template.name}"
    end
  end
end
