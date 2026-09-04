require 'test_helper'

class Oidc::HttpClientTest < ActiveSupport::TestCase
  let(:auth_source) { FactoryBot.build_stubbed(:auth_source_oidc, :cacert => nil) }
  let(:client) { Oidc::HttpClient.new(auth_source) }

  test 'loads a bounded JSON object over HTTPS' do
    stub_request(:get, 'https://idp.example.test/configuration')
      .to_return(:body => { :issuer => 'https://idp.example.test' }.to_json)

    response = client.get_json('https://idp.example.test/configuration')

    assert_equal 'https://idp.example.test', response['issuer']
  end

  test 'rejects unencrypted endpoints' do
    assert_raises(Oidc::ConfigurationError) do
      client.get_json('http://idp.example.test/configuration')
    end
  end

  test 'rejects endpoint credentials and fragments' do
    assert_raises(Oidc::ConfigurationError) do
      client.get_json('https://user:password@idp.example.test/configuration')
    end
    assert_raises(Oidc::ConfigurationError) do
      client.get_json('https://idp.example.test/configuration#fragment')
    end
  end

  test 'does not follow provider redirects' do
    stub_request(:get, 'https://idp.example.test/configuration')
      .to_return(:status => 302, :headers => { 'Location' => 'https://other.example.test/configuration' })

    assert_raises(Oidc::AuthenticationError) do
      client.get_json('https://idp.example.test/configuration')
    end
    assert_not_requested :get, 'https://other.example.test/configuration'
  end

  test 'rejects non-object JSON' do
    stub_request(:get, 'https://idp.example.test/configuration').to_return(:body => [].to_json)

    assert_raises(Oidc::AuthenticationError) do
      client.get_json('https://idp.example.test/configuration')
    end
  end
end
