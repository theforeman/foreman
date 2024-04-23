require 'test_helper'

class DebianTest < ActiveSupport::TestCase
  let(:operatingsystem) { FactoryBot.create(:debian7_1) }
  let(:medium) { FactoryBot.create(:medium, path: "http://ftp.at.debian.org/debian") }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }

  context 'Debian on Intel x86_64' do
    let(:architecture) { architectures(:x86_64) }

    describe '#bootfile' do
      test 'returns the bootfile' do
        assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'linux'
        assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.gz'
      end
    end

    describe '#boot_file_sources' do
      test 'returns all boot file sources' do
        expected = {
          kernel: 'http://ftp.at.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux',
          initrd: 'http://ftp.at.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz',
        }
        assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
      end
    end

    describe '#mediumpath' do
      test 'generates medium path url' do
        assert_equal 'http://ftp.at.debian.org/debian', operatingsystem.mediumpath(medium_provider)
      end
    end

    describe '#url_for_boot' do
      test 'generates kernel url' do
        assert_equal 'http://ftp.at.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux', operatingsystem.url_for_boot(medium_provider, :kernel)
      end

      test 'generates initrd url' do
        assert_equal 'http://ftp.at.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz', operatingsystem.url_for_boot(medium_provider, :initrd)
      end
    end

    describe '#preseed_path' do
      test 'returns preseed_path' do
        assert_equal '/debian', operatingsystem.preseed_path(medium_provider)
      end
    end

    describe '#preseed_path' do
      let(:medium) { FactoryBot.create(:medium, path: "http://ftp.at.debian.org/debian/$arch") }
      test 'returns preseed_path with arch transformation' do
        assert_equal '/debian/amd64', operatingsystem.preseed_path(medium_provider)
      end
    end
  end
end
