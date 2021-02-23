require 'test_helper'

class RedhatTest < ActiveSupport::TestCase
  let(:operatingsystem) { FactoryBot.create(:rhel7_5) }
  let(:medium) { FactoryBot.create(:medium, path: "http://mirror.example.com/rh/7.5") }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }

  context 'Red Hat on Intel x86_64' do
    let(:architecture) { architectures(:x86_64) }

    describe '#bootfile' do
      test 'returns the bootfile' do
        assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'vmlinuz'
        assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.img'
      end
    end

    describe '#boot_file_sources' do
      test 'returns all boot file sources' do
        expected = {
          kernel: 'http://mirror.example.com/rh/7.5/images/pxeboot/vmlinuz',
          initrd: 'http://mirror.example.com/rh/7.5/images/pxeboot/initrd.img',
        }
        assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
      end
    end

    describe '#mediumpath' do
      test 'generates medium path url' do
        assert_equal 'url --url http://mirror.example.com/rh/7.5', operatingsystem.mediumpath(medium_provider)
      end
    end

    describe '#url_for_boot' do
      test 'generates kernel url' do
        assert_equal 'http://mirror.example.com/rh/7.5/images/pxeboot/vmlinuz', operatingsystem.url_for_boot(medium_provider, :kernel)
      end

      test 'generates initrd url' do
        assert_equal 'http://mirror.example.com/rh/7.5/images/pxeboot/initrd.img', operatingsystem.url_for_boot(medium_provider, :initrd)
      end
    end
  end

  context 'Red Hat on IBM POWER' do
    let(:architecture) { architectures(:ppc64) }

    describe '#bootfile' do
      test 'returns the bootfile' do
        assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'vmlinuz'
        assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.img'
      end
    end

    describe '#boot_file_sources' do
      test 'returns all boot file sources' do
        expected = {
          kernel: 'http://mirror.example.com/rh/7.5/ppc/ppc64/vmlinuz',
          initrd: 'http://mirror.example.com/rh/7.5/ppc/ppc64/initrd.img',
        }
        assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
      end
    end

    describe '#mediumpath' do
      test 'generates medium path url' do
        assert_equal 'url --url http://mirror.example.com/rh/7.5', operatingsystem.mediumpath(medium_provider)
      end
    end

    describe '#url_for_boot' do
      test 'generates kernel url' do
        assert_equal 'http://mirror.example.com/rh/7.5/ppc/ppc64/vmlinuz', operatingsystem.url_for_boot(medium_provider, :kernel)
      end

      test 'generates initrd url' do
        assert_equal 'http://mirror.example.com/rh/7.5/ppc/ppc64/initrd.img', operatingsystem.url_for_boot(medium_provider, :initrd)
      end
    end
  end

  context 'Red Hat on IBM Z' do
    let(:architecture) { architectures(:s390x) }

    describe '#bootfile' do
      test 'returns the bootfile' do
        assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'vmlinuz'
        assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.img'
      end
    end

    describe '#boot_file_sources' do
      test 'returns all boot file sources' do
        expected = {
          kernel: 'http://mirror.example.com/rh/7.5/images/kernel.img',
          initrd: 'http://mirror.example.com/rh/7.5/images/initrd.img',
        }
        assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
      end
    end

    describe '#mediumpath' do
      test 'generates medium path url' do
        assert_equal 'url --url http://mirror.example.com/rh/7.5', operatingsystem.mediumpath(medium_provider)
      end
    end

    describe '#url_for_boot' do
      test 'generates kernel url' do
        assert_equal 'http://mirror.example.com/rh/7.5/images/kernel.img', operatingsystem.url_for_boot(medium_provider, :kernel)
      end

      test 'generates initrd url' do
        assert_equal 'http://mirror.example.com/rh/7.5/images/initrd.img', operatingsystem.url_for_boot(medium_provider, :initrd)
      end
    end
  end
end
