require "rest_client"
require "json"
require "uri"
require 'net'

module ProxyAPI

  class Resource
    attr_reader :url, :user, :password

    def initialize(args)
      raise("Must provide a protocol and host when initialising a smart-proxy connection") unless (url =~ /^http/)

      # Each request is limited to 60 seconds
      connect_params = {:timeout => 60, :open_timeout => 10, :headers => { :accept => :json }}

      # We authenticate only if we are using SSL
      if url.match(/^https/i)
        cert         = Setting[:ssl_certificate]
        ca_cert      = Setting[:ssl_ca_file]
        hostprivkey  = Setting[:ssl_priv_key]

        # Use update rather than merge! as this is not rails dependent
        connect_params.update(
          :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read(cert)),
          :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read(hostprivkey)),
          :ssl_ca_file      =>  ca_cert,
          :verify_ssl       =>  OpenSSL::SSL::VERIFY_PEER
        ) unless Rails.env == "test"
      end
      @resource = RestClient::Resource.new(url, connect_params)
    end

    def logger; RAILS_DEFAULT_LOGGER; end

    private

    # Decodes the JSON response if no HTTP error has been detected
    # If an HTTP error is received then the error message is saves into @error
    # Returns: Response, if the operation is GET, or true for POST, PUT and DELETE.
    #      OR: false if a HTTP error is detected
    # TODO: add error message handling
    def parse response
      if response and response.code >= 200 and response.code < 300
        return response.body.size > 2 ? JSON.parse(response.body) : true
      else
        false
      end
    rescue => e
      logger.warn "Failed to parse response: #{response} -> #{e}"
      false
    end

    # Perform GET operation on the supplied path
    def get path = nil
      # This ensures that an extra "/" is not generated
      if path
        @resource[URI.escape(path)].get
      else
        @resource.get
      end
    end

    # Perform POST operation with the supplied payload on the supplied path
    def post payload, path
      path ||= ""
      @resource[path].post payload
    end

    # Perform PUT operation with the supplied payload on the supplied path
    def put payload, path
      path ||= ""
      @resource[path].put payload
    end

    # Perform DELETE operation on the supplied path
    def delete path
      @resource[path].delete
    end
  end

  class Puppetca < Resource
    def initialize args
      @url  = args[:url] + "/puppet/ca"
      super args
    end

    def autosign
      result = parse(get "autosign")
      result == true ? [] : result
    end

    def set_autosign certname
      parse(post("", "autosign/#{certname}"))
    end

    def del_autosign certname
      parse(delete("autosign/#{certname}"))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      true
    end

    def sign_certificate certname
      parse(post("", certname))
    end

    def del_certificate certname
      parse(delete("#{certname}"))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      true
    end

    def all
      parse(get)
    end
  end

  class Features < Resource
    def initialize args
      @url  = args[:url] + "/features"
      super args
    end

    def features
      parse get
    end
  end

  class DHCP < Resource
    def initialize args
      @url  = args[:url] + "/dhcp"
      super args
    end

    # Retrieve the Server's subnets
    # Returns: Array of Hashes or false
    # Example [{"network":"192.168.11.0","netmask":"255.255.255.0"},{"network":"192.168.122.0","netmask":"255.255.255.0"}]
    def subnets
      parse get
    end

    def subnet subnet
      parse get(subnet)
    end

    def unused_ip subnet
      parse get("#{subnet}/unused_ip")
    end

    # Retrieves a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # Returns    : Hash or false
    def record subnet, mac
      response = parse(get("#{subnet}/#{mac}"))
      attrs = response.merge(:network => subnet, :proxy => self)
      if response.keys.grep(/Sun/i).empty?
        Net::DHCP::Record.new attrs
      else
        Net::DHCP::SparcRecord.new attrs
      end
    rescue RestClient::ResourceNotFound
      nil
    end

    # Sets a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # [+args+]   : Hash containing DHCP values. The :mac key is taken from the mac parameter
    # Returns    : Boolean status
    def set subnet, args
      raise "Must define a subnet" if subnet.empty?
      raise "Must provide arguments" unless args.is_a?(Hash)
      parse(post(args, subnet.to_s))
    end

    # Deletes a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # Returns    : Boolean status
    def delete subnet, mac
      parse super("#{subnet}/#{mac}")
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      return true
    end
  end

  class DNS < Resource
    def initialize args
      @url  = args[:url] + "/dns"
      super args
    end

    # Sets a DNS entry
    # [+fqdn+] : String containing the FQDN of the host
    # [+args+] : Hash containing :value and :type: The :fqdn key is taken from the fqdn parameter
    # Returns  : Boolean status
    def set args
      parse post(args, "")
    end

    # Deletes a DNS entry
    # [+key+] : String containing either a FQDN or a dotted quad plus .in-addr.arpa.
    # Returns    : Boolean status
    def delete key
      parse(super("#{key}"))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      return true
    end
  end

  class TFTP < Resource
    def initialize args
      @url     = args[:url] + "/tftp"
      @variant = args[:variant]
      super args
    end

    # Creates a TFTP boot entry
    # [+mac+]  : MAC address
    # [+args+] : Hash containing
    #    :pxeconfig => String containing the configuration
    # Returns  : Boolean status
    def set mac, args
      parse(post(args, "#{@variant}/#{mac}"))
    end

    # Deletes a TFTP boot entry
    # [+mac+] : String in coloned sextuplet format
    # Returns : Boolean status
    def delete mac
      parse(super("#{@variant}/#{mac}"))
    end

    # Requests that the proxy download the bootfile from the media's source
    # [+args+] : Hash containing
    #   :prefix => String containing the location within the TFTP tree to store the file
    #   :path   => String containing the URL of the file to download
    # Returns    : Boolean status
    def fetch_boot_file args
      parse(post(args, "fetch_boot_file"))
    end

    # returns the TFTP boot server for this proxy
    def bootServer
      response = parse get("serverName")
      if response and response["serverName"] and !response["serverName"].blank?
        return(response["serverName"] =~ /^\d/ ? response["serverName"] : dns_ptr_record.dns_lookup(response["serverName"]).ip)
      end
      false
    rescue RestClient::ResourceNotFound
      nil
    end

    # Create a default pxe menu
    # [+args+] : Hash containing
    #   :menu => String containing the menu text
    # Returns    : Boolean status
    def create_default args
      parse(post(args, "create_default"))
    end

  end
end
