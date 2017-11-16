# We need to patch Net:HTTP to add the options we need
class Net::HTTP
  SSL_IVNAMES << :@extra_chain_cert unless SSL_IVNAMES.include?(:@extra_chain_cert)
  SSL_ATTRIBUTES << :extra_chain_cert unless SSL_ATTRIBUTES.include?(:extra_chain_cert)

  attr_accessor :extra_chain_cert
end

# Monkey Patch for the RestClient
module SSLMonkeyPatches
  module RestClientRequest
    def net_http_object(hostname, port)
      net = super(hostname, port)
      extra_chain_cert = @ssl_opts[:extra_chain_cert]

      net.extra_chain_cert = extra_chain_cert if extra_chain_cert

      net
    end
  end
end

# add our extra_chain_cert to the RestClient::Request Option list
ssl_option_list = RestClient::Request::SSLOptionList
ssl_option_list << 'extra_chain_cert'
RestClient::Request.send(:remove_const, 'SSLOptionList')
RestClient::Request.const_set('SSLOptionList', ssl_option_list)

# prepend our MonkeyPatch for setting the extra_chain_cert option
RestClient::Request.send(:prepend, SSLMonkeyPatches::RestClientRequest)
