module HostFacets
  class ReportedDataFacet < Base
    def self.populate_fields_from_facts(host, parser, type, source_proxy)
      facet = host.reported_data || host.build_reported_data
      facet.attributes = {
        boot_time: parser.boot_timestamp,
        virtual: parser.virtual,
        ram: parser.ram,
        sockets: parser.sockets,
        cores: parser.cores,
        disks_total: parser.disks_total,
        kernel_version: parser.kernel_version,
      }.compact
      facet.save if facet.changed?
    end

    def boot_time=(val)
      val = Time.at(val) if val.is_a?(Numeric)
      super(val)
    end

    def uptime_seconds
      boot_time && Time.zone.now.to_i - boot_time.to_i
    end
  end
end
