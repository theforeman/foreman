class AddCloudProviderToReportedData < ActiveRecord::Migration[6.1]
  def change
    change_table(:host_facets_reported_data_facets) do |t|
      # Cloud provider identifier
      t.column :cloud_provider, :string, :limit => 255

      # AWS fields
      t.column :aws_account_id, :string, :limit => 255
      t.column :aws_billing_products, :string, :limit => 255
      t.column :aws_instance_id, :string, :limit => 255
      t.column :aws_instance_type, :string, :limit => 255
      t.column :aws_marketplace_product_codes, :string, :limit => 255
      t.column :aws_region, :string, :limit => 255

      # Azure fields
      t.column :azure_instance_id, :string, :limit => 255
      t.column :azure_offer, :string, :limit => 255
      t.column :azure_sku, :string, :limit => 255
      t.column :azure_subscription_id, :string, :limit => 255

      # GCP fields
      t.column :gcp_instance_id, :string, :limit => 255
      t.column :gcp_license_codes, :string, :limit => 255
      t.column :gcp_project_id, :string, :limit => 255
      t.column :gcp_project_number, :string, :limit => 255
      t.column :gcp_zone, :string, :limit => 255
    end
  end
end
