require 'test_helper'

class OperatingsystemsHelperTest < ActionView::TestCase
  include OperatingsystemsHelper

  test 'boot file action excludes NFS media without a boot path' do
    proxy = mock('TFTP proxy')
    os = mock('operating system')
    os.stubs(architectures: [Architecture.new(name: 'x86_64')])
    nfs_medium = Medium.new(id: 1, name: 'NFS medium', path: 'nfs://mirror.example.test/export')
    boot_path_medium = Medium.new(id: 2, name: 'NFS medium with BootPath',
      path: 'nfs://mirror.example.test/other', boot_path: 'https://boot.example.test/files')
    os.stubs(media: [nfs_medium, boot_path_medium])
    stubs(:boot_file_proxies).returns([proxy])
    stubs(:authorizer).returns(stub(can?: true))
    stubs(:sync_boot_files_operatingsystem_path).returns('/sync')
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).with(proxy, os).returns(true)
    Medium.stubs(:authorized).with(:view_media).returns(stub(pluck: [1, 2]))

    actions = bootloader_medium_actions(os)

    assert_equal 1, actions.size
    assert_includes actions.first, boot_path_medium.name
  end

  describe '#icon' do
    let(:custom_operatingsystem) { FactoryBot.create(:operatingsystem, name: 'randomname_without_family') }

    it 'returns path for custom operatingsystem without family' do
      assert_match /^\/images\/icons.*\/stub\/.*png$/, icon(custom_operatingsystem, path: true)
    end
  end
end
