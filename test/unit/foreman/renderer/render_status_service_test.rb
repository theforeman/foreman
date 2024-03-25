require 'test_helper'

class RenderStatusServiceTests < ActiveSupport::TestCase
  let(:provisioning_template) { FactoryBot.create(:provisioning_template, template: '<%= @host.name %>') }

  context 'for an existing host' do
    let(:host) { FactoryBot.create(:host, :managed) }

    it 'saves the render status' do
      assert_difference('RenderStatus.count', 1) do
        provisioning_template.render(host: host)
      end
    end

    context 'when render status already exists' do
      setup do
        FactoryBot.create(:render_status, host: host, provisioning_template: provisioning_template, success: false)
      end

      it 'updates the render status' do
        assert_not RenderStatus.find_by(host: host, provisioning_template: provisioning_template).success

        provisioning_template.render(host: host)

        assert RenderStatus.find_by(host: host, provisioning_template: provisioning_template).success
      end
    end
  end

  context 'for a new host' do
    let(:host) { FactoryBot.build(:host, :managed) }

    it 'saves the render status with the host' do
      provisioning_template.render(host: host)

      assert_difference('RenderStatus.count', 1) do
        host.save!
      end
    end
  end

  context 'for an existing hostgroup' do
    let(:hostgroup) { FactoryBot.create(:hostgroup) }

    it 'saves the render status' do
      assert_difference('RenderStatus.count', 1) do
        provisioning_template.render(host: hostgroup)
      end
    end

    context 'when render status already exists' do
      setup do
        FactoryBot.create(:render_status, :with_hostgroup, hostgroup: hostgroup, provisioning_template: provisioning_template, success: false)
      end

      it 'updates the render status' do
        assert_not RenderStatus.find_by(hostgroup: hostgroup, provisioning_template: provisioning_template).success

        provisioning_template.render(host: hostgroup)

        assert RenderStatus.find_by(hostgroup: hostgroup, provisioning_template: provisioning_template).success
      end
    end
  end

  context 'for a new hostgroup' do
    let(:hostgroup) { FactoryBot.build(:hostgroup) }

    it 'saves the render status with the hostgroup' do
      provisioning_template.render(host: hostgroup)

      assert_difference('RenderStatus.count', 1) do
        hostgroup.save!
      end
    end
  end
end
