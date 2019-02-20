require 'test_helper'

class TemplateRenderJobTest < ActiveJob::TestCase
  def setup
    @job = TemplateRenderJob.new('foo' => 'bar')
    @job.provider_job_id = 'UNIQUE-PROVIDER-ID'
  end

  it 'calls ReportComposer to render and store report' do
    composer = MiniTest::Mock.new
    composer.expect('render_to_store', nil, ['UNIQUE-PROVIDER-ID'])
    ReportComposer.expects('new').with('foo' => 'bar').returns(composer)
    @job.perform_now
    assert composer.verify
  end
end
