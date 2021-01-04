module ProxyStatus
  class Puppetca < Base
    def certs
      fetch_proxy_data('/certs') do
        api.all.map do |name, properties|
          SmartProxies::PuppetCACertificate.new([name.strip, properties['state'], properties['fingerprint'], properties["not_before"], properties["not_after"], self])
        end.compact
      end
    end

    def find(name)
      certs.find { |c| c.name == name }
    end

    def find_by_state(state)
      certs.select { |c| c.state == state }
    end

    def expiry
      ca_cert = find_by_state('valid').select { |c| c.valid_from.present? }.min_by(&:valid_from)
      if ca_cert.present?
        ca_cert.expires_at
      else
        _("Could not locate CA certificate.")
      end
    end

    def sign(cert)
      revoke_cache!('/certs')
      api.sign_certificate(cert)
    end

    def destroy(cert)
      revoke_cache!('/certs')
      api.del_certificate(cert)
    end

    def autosign
      fetch_proxy_data('/autosign') do
        api.autosign
      end
    end

    def set_autosign(id)
      revoke_cache!('/autosign')
      api.set_autosign(id)
    end

    def del_autosign(id)
      revoke_cache!('/autosign')
      api.del_autosign(id)
    end

    def revoke_cache!(subkey = nil)
      if subkey.present?
        super(subkey)
      else
        super('/certs')
        super('/autosign')
      end
    end

    def self.humanized_name
      'PuppetCA'
    end

    protected

    def api_class
      ProxyAPI::Puppetca
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::Puppetca)
