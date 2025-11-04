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
        bios_vendor: parser.bios[:vendor],
        bios_release_date: parser.bios[:release_date],
        bios_version: parser.bios[:version],
        cloud_provider: parser.cloud_provider,
        aws_account_id: parser.aws_account_id,
        aws_billing_products: parser.aws_billing_products,
        aws_instance_id: parser.aws_instance_id,
        aws_instance_type: parser.aws_instance_type,
        aws_marketplace_product_codes: parser.aws_marketplace_product_codes,
        aws_region: parser.aws_region,
        azure_instance_id: parser.azure_instance_id,
        azure_offer: parser.azure_offer,
        azure_sku: parser.azure_sku,
        azure_subscription_id: parser.azure_subscription_id,
        gcp_instance_id: parser.gcp_instance_id,
        gcp_license_codes: parser.gcp_license_codes,
        gcp_project_id: parser.gcp_project_id,
        gcp_project_number: parser.gcp_project_number,
        gcp_zone: parser.gcp_zone,
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
