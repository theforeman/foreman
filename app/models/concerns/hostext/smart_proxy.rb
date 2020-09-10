module Hostext
  module SmartProxy
    extend ActiveSupport::Concern

    def smart_proxies
      ::SmartProxy.where(:id => smart_proxy_ids)
    end

    def smart_proxy_ids
      ids = []
      [subnet, subnet6].compact.each do |s|
        ids << s.dhcp_id
        ids << s.tftp_id
        ids << s.dns_id
      end
      ids << domain.dns_id if domain.present?
      ids << realm.realm_proxy_id if realm.present?
      ids += [puppet_proxy_id, puppet_ca_proxy_id]
      ids.uniq.compact
    end
  end
end
