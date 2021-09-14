require 'test_helper'

class CoreosTest < ActiveSupport::TestCase
  let(:architecture) { architectures(:x86_64) }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }

  context 'CoreOS Container Linux' do
    let(:operatingsystem) { FactoryBot.create(:coreos) }
    let(:medium) { FactoryBot.create(:medium, :coreos) }

    describe '#bootfile' do
      test 'returns the bootfile' do
        assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'coreos_production_pxe.vmlinuz'
      end
    end

    describe '#boot_file_sources' do
      test 'returns all boot file sources' do
        expected = {
          kernel: 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe.vmlinuz',
          initrd: 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe_image.cpio.gz',
        }
        assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
      end
    end

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

  context 'Flatcar Container Linux' do
    let(:operatingsystem) { FactoryBot.create(:flatcar) }
    let(:medium) { FactoryBot.create(:medium, :flatcar) }

    describe '#bootfile' do
      test 'returns the bootfile' do
        assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'flatcar_production_pxe.vmlinuz'
      end
    end

    describe '#boot_file_sources' do
      test 'returns all boot file sources' do
        expected = {
          kernel: 'http://stable.release.flatcar-linux.net/amd64-usr/2345.3.0/flatcar_production_pxe.vmlinuz',
          initrd: 'http://stable.release.flatcar-linux.net/amd64-usr/2345.3.0/flatcar_production_pxe_image.cpio.gz',
        }
        assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
      end
    end

    describe '#url_for_boot' do
      test 'generates kernel url' do
        assert_equal 'http://stable.release.flatcar-linux.net/amd64-usr/2345.3.0/flatcar_production_pxe.vmlinuz', operatingsystem.url_for_boot(medium_provider, :kernel)
      end

      test 'generates initrd url' do
        assert_equal 'http://stable.release.flatcar-linux.net/amd64-usr/2345.3.0/flatcar_production_pxe_image.cpio.gz', operatingsystem.url_for_boot(medium_provider, :initrd)
      end
    end
  end

  context 'Flatcar Container Linux current version' do
    let(:operatingsystem) { FactoryBot.create(:flatcar, major: "0") }
    let(:medium) { FactoryBot.create(:medium, :flatcar) }

    describe '#bootfile' do
      test 'returns the bootfile' do
        assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'flatcar_production_pxe.vmlinuz'
      end
    end

    describe '#boot_file_sources' do
      test 'returns all boot file sources' do
        expected = {
          kernel: 'http://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz',
          initrd: 'http://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz',
        }
        assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
      end
    end

    describe '#url_for_boot' do
      test 'generates kernel url' do
        assert_equal 'http://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz', operatingsystem.url_for_boot(medium_provider, :kernel)
      end

      test 'generates initrd url' do
        assert_equal 'http://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz', operatingsystem.url_for_boot(medium_provider, :initrd)
      end
    end
  end
end
