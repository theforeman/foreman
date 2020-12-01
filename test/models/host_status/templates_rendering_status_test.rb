require 'test_helper'

class TemplatesRenderingStatusTest < ActiveSupport::TestCase
  describe '#refresh!' do
    let(:combination) { FactoryBot.create(:templates_rendering_status_combination) }
    let(:status) { combination.host_status }
    let(:host) { status.host }

    test 'remove old combinations' do
      host.expects(:find_templates).returns([])

      assert_difference('HostStatus::TemplatesRenderingStatusCombination.count', -1) do
        status.refresh!
      end
    end

    test 'create new combinations' do
      host.expects(:find_templates).returns(
        [
          combination.template,
          FactoryBot.create(:provisioning_template),
        ]
      )

      assert_difference('HostStatus::TemplatesRenderingStatusCombination.count', 1) do
        status.refresh!
      end
    end

    test 'update exisiting combinations' do
      host.expects(:find_templates).returns([combination.template])
      HostStatus::TemplatesRenderingStatusCombination.any_instance.expects(:refresh_status).once

      assert_difference('HostStatus::TemplatesRenderingStatusCombination.count', 0) do
        status.refresh!
      end
    end
  end
end
