require 'test_helper'

class ProxyAPI::TFTPTest < ActiveSupport::TestCase
  test 'checks bootloader universe readiness with the requested paths' do
    api = ProxyAPI::TFTP.new(url: 'http://proxy.example.test')
    query = {
      targetos: 'centos_stream', release: '10', arch: 'x86_64',
      universe_kernel: 'bootloader-universe/pxegrub2/centos_stream/10/x86_64/vmlinuz',
      universe_initrd: 'bootloader-universe/pxegrub2/centos_stream/10/x86_64/initrd.img'
    }
    response = mock('response')
    api.expects(:get).with('universe_boot_files', query: query).returns(response)
    api.expects(:parse).with(response).returns('ready' => true)

    assert api.universe_boot_files_ready?(query)
  end

  test 'treats an unavailable readiness endpoint as unready' do
    api = ProxyAPI::TFTP.new(url: 'http://proxy.example.test')
    api.stubs(:get).raises(RestClient::ResourceNotFound)

    assert_not api.universe_boot_files_ready?({})
  end
end
