require_dependency "proxy_api"

class SmartProxies::PuppetCA

  attr_reader :name, :state, :fingerprint, :smart_proxy_id

  def initialize opts
    @name, @state, @fingerprint, @smart_proxy_id = opts.flatten
  end

    class << self

      def all(proxy)
        raise "Must specify a Smart Proxy to use" if proxy.nil?

        unless certs = Rails.cache.read("ca_#{proxy.id}")
          api = ProxyAPI::Puppetca.new({:url => proxy.url})

          certs = api.all.map do |name, properties|
            new([name, properties['state'], properties['fingerprint'], proxy.id])
          end.compact

          # save our CA details for 5 seconds
          Rails.cache.write("ca_#{proxy.id}", certs, {:expires_in  => 1.minute })
        end
        certs
      end

      def find(proxy, name)
        all(proxy).select{|c| c.name == name}.first
      rescue
        raise ActiveRecord::RecordNotFound
      end
    end

  def sign
    raise "unable to sign a non pending certificate" unless state == "pending"
    proxy = SmartProxy.find(smart_proxy_id)
    Rails.cache.delete("ca_#{proxy.id}")
    ProxyAPI::Puppetca.new({:url => proxy.url}).sign_certificate name
  end

  def destroy
    proxy = SmartProxy.find(smart_proxy_id)
    Rails.cache.delete("ca_#{proxy.id}")
    ProxyAPI::Puppetca.new({:url => proxy.url}).del_certificate name
  end

  def to_param; name; end

  def to_s; name; end

end