require "time"

class SmartProxies::PuppetCA

  attr_reader :name, :state, :fingerprint, :valid_from, :expires_at, :smart_proxy_id

  def initialize opts
    @name, @state, @fingerprint, @valid_from, @expires_at, @smart_proxy_id = opts.flatten
    @valid_from = Time.parse(@valid_from) unless @valid_from.blank?
    @expires_at = Time.parse(@expires_at) unless @expires_at.blank?
  end

    class << self

      def all(proxy)
        raise ::Foreman::Exception.new(N_("Must specify a Smart Proxy to use")) if proxy.nil?

        unless (certs = Rails.cache.read("ca_#{proxy.id}"))
          api = ProxyAPI::Puppetca.new({:url => proxy.url})

          certs = api.all.map do |name, properties|
            new([name.strip, properties['state'], properties['fingerprint'], properties["not_before"], properties["not_after"], proxy.id])
          end.compact

          # save our CA details for 5 seconds
          Rails.cache.write("ca_#{proxy.id}", certs, {:expires_in  => 1.minute }) if Rails.env.production?
        end
        certs
      end

      def find(proxy, name)
        all(proxy).select{|c| c.name == name}.first
      rescue
        raise ActiveRecord::RecordNotFound
      end

      def find_by_state(proxy, state)
         all(proxy).select{|c| c.state == state}
      rescue
        raise ActiveRecord::RecordNotFound
      end
    end

  def sign
    raise ::Foreman::Exception.new(N_("unable to sign a non pending certificate")) unless state == "pending"
    proxy = SmartProxy.find(smart_proxy_id)
    Rails.cache.delete("ca_#{proxy.id}") if Rails.env.production?
    ProxyAPI::Puppetca.new({:url => proxy.url}).sign_certificate name
  end

  def destroy
    proxy = SmartProxy.find(smart_proxy_id)
    Rails.cache.delete("ca_#{proxy.id}") if Rails.env.production?
    ProxyAPI::Puppetca.new({:url => proxy.url}).del_certificate name
  end

  def to_param; name end

  def to_s; name end

  def <=> other
    self.name <=> other.name
  end

end
