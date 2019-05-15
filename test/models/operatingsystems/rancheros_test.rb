require 'test_helper'

class RancherosTest < ActiveSupport::TestCase
  let(:operatingsystem) { FactoryBot.create(:rancheros) }
  let(:architecture) { architectures(:x86_64) }
  let(:medium) { FactoryBot.create(:medium, :rancheros) }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }

  describe '#mediumpath' do
    test 'generates empty medium path url' do
      assert_equal '', operatingsystem.mediumpath(medium_provider)
    end
  end

  describe '#url_for_boot' do
    test 'generates kernel url' do
      assert_equal 'https://github.com/rancher/os/releases/download/v1.4.3/vmlinuz', operatingsystem.url_for_boot(medium_provider, :kernel)
    end

    test 'generates initrd url' do
      assert_equal 'https://github.com/rancher/os/releases/download/v1.4.3/initrd', operatingsystem.url_for_boot(medium_provider, :initrd)
    end
  end
end
