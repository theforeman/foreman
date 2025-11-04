glue(@facet) do
  attributes :uptime_seconds
end

child(@facet => :reported_data) do
  attributes :boot_time, :cores, :sockets, :ram, :disks_total, :kernel_version, :bios_vendor, :bios_release_date, :bios_version, :virtual,
    :aws_account_id, :aws_billing_products, :aws_instance_id, :aws_instance_type, :aws_marketplace_product_codes, :aws_region,
    :azure_instance_id, :azure_offer, :azure_sku, :azure_subscription_id,
    :gcp_instance_id, :gcp_license_codes, :gcp_project_id, :gcp_project_number, :gcp_zone
end
