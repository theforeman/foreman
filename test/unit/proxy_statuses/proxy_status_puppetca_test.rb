require 'test_helper'

class ProxyStatusPuppetcaTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryBot.build_stubbed(:smart_proxy, :url => 'https://secure.proxy:4568')
    # don't cache because the mock breaks when trying to cache the array of certs
    @proxy_status = ProxyStatus::PuppetCA.new(@proxy, :cache => false)
  end

  context 'CA has certificates' do
    setup do
      certificates = { "proxy.host2" => {"state" => "valid", "fingerprint" => "SHA256", "serial" => 3, "not_before" => "2015-12-25T14:33:10UTC", "not_after" => "2020-12-25T14:33:10UTC"},
                       "secure.proxy" => {"state" => "valid", "fingerprint" => "SHA256", "serial" => 1, "not_before" => "2015-12-12T14:33:10UTC", "not_after" => "2020-12-11T14:33:10UTC"},
                       "proxy.host" => {"state" => "valid", "fingerprint" => "SHA256", "serial" => 2, "not_before" => "2015-12-22T14:33:10UTC", "not_after" => "2020-12-22T14:33:10UTC"},
                       "proxy.host.with_no_dates" => {"state" => "valid", "fingerprint" => "SHA256", "serial" => 5, "not_before" => nil, "not_after" => nil},
                       "refuted.host" => {"state" => "refuted", "fingerprint" => "SHA256", "serial" => 4, "not_before" => "2015-12-22T14:33:10UTC", "not_after" => "2020-12-22T14:33:10UTC"},
                       "pending.host" => {"state" => "pending", "fingerprint" => "SHA256", "serial" => 6}}
      ProxyAPI::Puppetca.any_instance.stubs(:all).returns(certificates)
    end

    test 'it returns all certificates' do
      certs = @proxy_status.certs
      assert_equal(6, certs.length)
    end

    test 'it returns CA certificate by hostname with all fields parsed' do
      cert = @proxy_status.find(@proxy.hostname)
      assert_kind_of SmartProxies::PuppetCACertificate, cert
      assert_equal(cert.name, @proxy.hostname)
      assert_equal(cert.state, "valid")
      assert_equal(cert.fingerprint, "SHA256")
      assert_equal(cert.valid_from, Time.parse("2015-12-12T14:33:10UTC").utc)
      assert_equal(cert.expires_at, Time.parse("2020-12-11T14:33:10UTC").utc)
      assert_equal(cert.status_object, @proxy_status)
    end

    test 'it returns expiry for CA certificate' do
      # the CA certificate should be the oldest valid certificate, as it signs all others
      assert_equal(Time.parse("2020-12-11T14:33:10UTC").utc, @proxy_status.expiry)
    end
  end

  context 'CA has no certificates' do
    setup do
      ProxyAPI::Puppetca.any_instance.stubs(:all).returns({})
    end

    test 'it returns no certificates' do
      certs = @proxy_status.certs
      assert_equal(0, certs.length)
    end

    test 'it returns no expiry for CA certificate' do
      # the CA certificate should be the oldest certificate, as it signs all others
      assert_equal("Could not locate CA certificate.", @proxy_status.expiry)
    end
  end

  test 'it allows signing a certificate' do
    ProxyAPI::Puppetca.any_instance.expects(:sign_certificate).with('certificate_name').returns(true)
    @proxy_status.sign('certificate_name')
  end

  test 'it allows revoking a certificate' do
    ProxyAPI::Puppetca.any_instance.expects(:del_certificate).with('certificate_name').returns(true)
    @proxy_status.destroy('certificate_name')
  end

  test 'it returns autosign entries' do
    ProxyAPI::Puppetca.any_instance.expects(:autosign).returns(['autosigned.com'])
    assert_equal('autosigned.com', @proxy_status.autosign[0])
  end

  test 'it allows adding an autosign entry' do
    ProxyAPI::Puppetca.any_instance.expects(:set_autosign).with('host.name').returns(true)
    @proxy_status.set_autosign('host.name')
  end

  test 'it allows removing an autosign entry' do
    ProxyAPI::Puppetca.any_instance.expects(:del_autosign).with('host.name').returns(true)
    @proxy_status.del_autosign('host.name')
  end
end
