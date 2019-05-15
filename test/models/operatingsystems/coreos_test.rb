require 'test_helper'

class CoreosTest < ActiveSupport::TestCase
  let(:operatingsystem) { FactoryBot.create(:coreos) }
  let(:architecture) { architectures(:x86_64) }
  let(:medium) { FactoryBot.create(:medium, :coreos) }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }

  describe '#mediumpath' do
    test 'generates medium path url' do
      assert_equal 'http://stable.release.core-os.net/amd64-usr/', operatingsystem.mediumpath(medium_provider)
    end
  end

  describe '#url_for_boot' do
    test 'generates kernel url' do
      assert_equal 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe.vmlinuz', operatingsystem.url_for_boot(medium_provider, :kernel)
    end

    test 'generates initrd url' do
      assert_equal 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe_image.cpio.gz', operatingsystem.url_for_boot(medium_provider, :initrd)
    end
  end
end
