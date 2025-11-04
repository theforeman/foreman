class AddCloudBillingToHostFacets < ActiveRecord::Migration[6.1]
  def up
    # AWS fields
    add_column :host_facets_reported_data_facets, :aws_account_id, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :aws_billing_products, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :aws_instance_id, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :aws_instance_type, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :aws_marketplace_product_codes, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :aws_region, :string, :limit => 255

    # Azure fields
    add_column :host_facets_reported_data_facets, :azure_instance_id, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :azure_offer, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :azure_sku, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :azure_subscription_id, :string, :limit => 255

    # GCP fields
    add_column :host_facets_reported_data_facets, :gcp_instance_id, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :gcp_license_codes, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :gcp_project_id, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :gcp_project_number, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :gcp_zone, :string, :limit => 255
  end

  def down
    # AWS fields
    remove_column :host_facets_reported_data_facets, :aws_account_id
    remove_column :host_facets_reported_data_facets, :aws_billing_products
    remove_column :host_facets_reported_data_facets, :aws_instance_id
    remove_column :host_facets_reported_data_facets, :aws_instance_type
    remove_column :host_facets_reported_data_facets, :aws_marketplace_product_codes
    remove_column :host_facets_reported_data_facets, :aws_region

    # Azure fields
    remove_column :host_facets_reported_data_facets, :azure_instance_id
    remove_column :host_facets_reported_data_facets, :azure_offer
    remove_column :host_facets_reported_data_facets, :azure_sku
    remove_column :host_facets_reported_data_facets, :azure_subscription_id

    # GCP fields
    remove_column :host_facets_reported_data_facets, :gcp_instance_id
    remove_column :host_facets_reported_data_facets, :gcp_license_codes
    remove_column :host_facets_reported_data_facets, :gcp_project_id
    remove_column :host_facets_reported_data_facets, :gcp_project_number
    remove_column :host_facets_reported_data_facets, :gcp_zone
  end
end
