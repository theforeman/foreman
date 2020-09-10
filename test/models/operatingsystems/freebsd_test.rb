require 'test_helper'

class FreebsdTest < ActiveSupport::TestCase
  let(:operatingsystem) { FactoryBot.create(:freebsd) }
  let(:architecture) { architectures(:x86_64) }
  let(:medium) { FactoryBot.create(:medium, :freebsd) }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }

  describe '#mediumpath' do
    test 'generates the medium path url' do
      assert_equal 'http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.2-RELEASE', operatingsystem.mediumpath(medium_provider)
    end
  end

  describe '#kernel' do
    test 'defauls the kernel to memdisk' do
      assert_equal 'memdisk', operatingsystem.kernel(medium_provider)
    end
  end

  describe '#initrd' do
    test 'builds initrd url' do
      assert_equal 'boot/FreeBSD-x86_64-11.2-mfs.img', operatingsystem.initrd(medium_provider)
    end
  end
end
