require 'test_helper'

class SmartProxyPoolTest < ActiveSupport::TestCase
  context 'smart_proxy_pool validations' do
    setup do
      @smart_proxy_pool = FactoryBot.build(:smart_proxy_pool)
    end

    test "should be valid" do
      assert_valid @smart_proxy_pool
    end

    test "should save" do
      assert @smart_proxy_pool.save
    end

    test "should save with the same smart proxy features" do
      proxy1 = FactoryBot.create(:smart_proxy, :with_ssl, :features => [features(:dns)])
      proxy2 = FactoryBot.create(:smart_proxy, :with_ssl, :features => [features(:dns)])

      mock_cert = mock()
      mock_cert.expects(:subject).at_least_once.returns(@smart_proxy_pool.hostname)
      mock_cert.expects(:subject_alternative_names).at_least_once
        .returns([proxy1.hostname, proxy2.hostname])
      CertificateExtract.expects(:new).twice.with(mock_cert).returns(mock_cert)

      mock_conn = mock()
      mock_conn.expects(:cert).at_least_once.returns(mock_cert)
      GetRawCertificate.expects(:new).with(proxy1.hostname, proxy1.port).returns(mock_conn)
      GetRawCertificate.expects(:new).with(proxy2.hostname, proxy2.port).returns(mock_conn)
      @smart_proxy_pool.smart_proxies = [proxy1, proxy2]
      assert @smart_proxy_pool.save
    end

    test "should fail with different smart proxy features" do
      @smart_proxy_pool.smart_proxies = [smart_proxies(:logs), smart_proxies(:bmc)]
      refute @smart_proxy_pool.save
    end

    test "should save if certs have valid san" do
      mock_cert = mock()
      mock_cert.expects(:subject).at_least_once.returns('proxy.example.com')
      mock_cert.expects(:subject_alternative_names).at_least_once.returns([@smart_proxy_pool.hostname])
      CertificateExtract.expects(:new).with(mock_cert).returns(mock_cert)

      mock_conn = mock()
      mock_conn.expects(:cert).at_least_once.returns(mock_cert)
      GetRawCertificate.expects(:new).with('proxy.example.com', 8443).returns(mock_conn)

      @smart_proxy_pool.smart_proxies = [FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')]
      assert @smart_proxy_pool.save
    end

    test "should fail if certs arent valid" do
      mock_cert = mock()
      mock_cert.expects(:subject).at_least_once.returns('proxy.example.com')
      mock_cert.expects(:subject_alternative_names).at_least_once.returns([])
      CertificateExtract.expects(:new).with(mock_cert).returns(mock_cert)

      mock_conn = mock()
      mock_conn.expects(:cert).at_least_once.returns(mock_cert)
      GetRawCertificate.expects(:new).with('proxy.example.com', 8443).returns(mock_conn)

      @smart_proxy_pool.smart_proxies = [FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')]
      refute @smart_proxy_pool.save
    end
  end

  test "proxy should respond correctly to has_feature? method" do
    assert smart_proxy_pools(:puppetmaster).has_feature?('Puppet')
    refute smart_proxy_pools(:realm).has_feature?('Puppet')
  end
end
