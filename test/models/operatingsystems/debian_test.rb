require 'test_helper'

class DebianTest < ActiveSupport::TestCase
  let(:medium) { FactoryBot.create(:medium, path: "http://mirror.example.com/debian/$major.$minor") }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }
  let(:architecture) { architectures(:x86_64) }

  context 'Debian 7.1' do
    let(:operatingsystem) { FactoryBot.create(:debian7_1) }

    test 'returns the bootfile' do
      assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'linux'
      assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.gz'
    end

    test 'generates medium path url' do
      assert_equal 'http://mirror.example.com/debian/7.1', operatingsystem.mediumpath(medium_provider)
    end

    test 'returns all boot file sources' do
      expected = {
        kernel: 'http://mirror.example.com/debian/7.1/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux',
        initrd: 'http://mirror.example.com/debian/7.1/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz',
      }
      assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
    end

    test 'returns url for boot' do
      kernel = 'http://mirror.example.com/debian/7.1/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux'
      initrd = 'http://mirror.example.com/debian/7.1/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz'
      assert_equal kernel, operatingsystem.url_for_boot(medium_provider, :kernel)
      assert_equal initrd, operatingsystem.url_for_boot(medium_provider, :initrd)
    end
  end

  context 'Ubuntu 18.04' do
    let(:operatingsystem) { FactoryBot.create(:ubuntu18_04) }

    test 'returns the bootfile' do
      assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'linux'
      assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.gz'
    end

    test 'generates medium path url' do
      assert_equal 'http://mirror.example.com/debian/18.04', operatingsystem.mediumpath(medium_provider)
    end

    test 'returns all boot file sources' do
      expected = {
        kernel: 'http://mirror.example.com/debian/18.04/dists/bionic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux',
        initrd: 'http://mirror.example.com/debian/18.04/dists/bionic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz',
      }
      assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
    end

    test 'returns url for boot' do
      kernel = 'http://mirror.example.com/debian/18.04/dists/bionic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux'
      initrd = 'http://mirror.example.com/debian/18.04/dists/bionic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz'
      assert_equal kernel, operatingsystem.url_for_boot(medium_provider, :kernel)
      assert_equal initrd, operatingsystem.url_for_boot(medium_provider, :initrd)
    end
  end

  context 'Ubuntu 20.04' do
    let(:operatingsystem) { FactoryBot.create(:ubuntu20_04) }

    test 'returns the bootfile' do
      assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'linux'
      assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.gz'
    end

    test 'generates medium path url' do
      assert_equal 'http://mirror.example.com/debian/20.04', operatingsystem.mediumpath(medium_provider)
    end

    test 'returns all boot file sources' do
      expected = {
        kernel: 'http://mirror.example.com/debian/20.04/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/linux',
        initrd: 'http://mirror.example.com/debian/20.04/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/initrd.gz',
      }
      assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
    end

    test 'returns url for boot' do
      kernel = 'http://mirror.example.com/debian/20.04/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/linux'
      initrd = 'http://mirror.example.com/debian/20.04/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/initrd.gz'
      assert_equal kernel, operatingsystem.url_for_boot(medium_provider, :kernel)
      assert_equal initrd, operatingsystem.url_for_boot(medium_provider, :initrd)
    end
  end

  context 'Ubuntu 21.10' do
    let(:operatingsystem) { FactoryBot.create(:ubuntu21_10) }

    test 'returns the bootfile' do
      assert_includes operatingsystem.bootfile(medium_provider, :kernel), 'linux'
      assert_includes operatingsystem.bootfile(medium_provider, :initrd), 'initrd.gz'
    end

    test 'generates medium path url' do
      assert_equal 'http://mirror.example.com/debian/21.10', operatingsystem.mediumpath(medium_provider)
    end

    test 'returns all boot file sources' do
      expected = {
        kernel: 'http://downloads.theforeman.org/netboot-files/ubuntu-21.10-x86_64-linux',
        initrd: 'http://downloads.theforeman.org/netboot-files/ubuntu-21.10-x86_64-initrd.gz',
      }
      assert_equal expected, operatingsystem.boot_file_sources(medium_provider)
    end

    test 'returns url for boot' do
      kernel = 'http://downloads.theforeman.org/netboot-files/ubuntu-21.10-x86_64-linux'
      initrd = 'http://downloads.theforeman.org/netboot-files/ubuntu-21.10-x86_64-initrd.gz'
      assert_equal kernel, operatingsystem.url_for_boot(medium_provider, :kernel)
      assert_equal initrd, operatingsystem.url_for_boot(medium_provider, :initrd)
    end
  end
end
