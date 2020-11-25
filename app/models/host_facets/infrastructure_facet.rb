module HostFacets
  class InfrastructureFacet < Base

    belongs_to :smart_proxy

    def self.populate_fields_from_facts(host, parser, type, source_proxy)
      # Do not do anything if there are no relevant facts
      return unless parser.foreman_uuid || parser.smart_proxy_uuid

      facet = host.infrastructure_facet || host.build_infrastructure_facet
      facet.foreman_uuid = parser.foreman_uuid
      facet.smart_proxy_uuid = parser.smart_proxy_uuid
      facet.refresh_associations!
      facet.save if facet.changed?
    end

    def any_foreman?
      self.foreman_uuid.present?
    end

    def this_foreman?
      any_foreman? && ::Foreman.instance_id == self.foreman_uuid
    end

    def refresh_associations!
      if changed.include?('smart_proxy_uuid') || (self.smart_proxy_uuid && smart_proxy_id.nil?)
        self.smart_proxy_id = ::SmartProxy.find_by(:uuid => self.smart_proxy_uuid)&.id
      end
    end
  end
end
