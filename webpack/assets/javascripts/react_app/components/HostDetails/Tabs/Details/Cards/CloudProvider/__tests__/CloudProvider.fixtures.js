// AWS billing data fixtures
export const awsBillingDataComplete = {
  cloud_provider: 'aws',
  aws_account_id: '340706125509',
  aws_billing_products: 'bp-6fa54006',
  aws_instance_id: 'i-07283719ca51ec39e',
  aws_instance_type: 't3.micro',
  aws_marketplace_product_codes: 'marketplace-code-123',
  aws_region: 'us-east-2',
};

export const awsBillingDataPartial = {
  cloud_provider: 'aws',
  aws_account_id: '340706125509',
  aws_instance_type: 't3.micro',
  aws_region: 'us-east-2',
};

export const awsBillingDataMinimal = {
  cloud_provider: 'aws',
  aws_account_id: '340706125509',
};

// GCP billing data fixtures
export const gcpBillingDataComplete = {
  cloud_provider: 'gcp',
  gcp_instance_id: '1301731395666156002',
  gcp_license_codes: '7883559014960410759',
  gcp_project_id: 'sat-eng',
  gcp_project_number: '1082392642010',
  gcp_zone: 'us-central1-a',
};

export const gcpBillingDataMinimal = {
  cloud_provider: 'gcp',
  gcp_license_codes: '7883559014960410759',
};

// Azure billing data fixtures
export const azureBillingDataComplete = {
  cloud_provider: 'azure',
  azure_instance_id: 'cc6e8455-3523-4d98-8445-39dd17403a2a',
  azure_offer: 'RHEL',
  azure_sku: '94_gen2',
  azure_subscription_id: 'ace931ad-539b-4ce1-b392-a7e60a28cc94',
};

export const azureBillingDataMinimal = {
  cloud_provider: 'azure',
  azure_subscription_id: 'ace931ad-539b-4ce1-b392-a7e60a28cc94',
};

// Host details fixtures
export const hostDetailsAws = {
  id: 1,
  compute_resource_provider: 'ec2',
  reported_data: {},
};

export const hostDetailsGcp = {
  id: 2,
  compute_resource_provider: 'gce',
  reported_data: {},
};

export const hostDetailsAzure = {
  id: 3,
  compute_resource_provider: 'azurerm',
  reported_data: {},
};

export const hostDetailsNonCloud = {
  id: 4,
  compute_resource_provider: 'libvirt',
  reported_data: {},
};

export const hostDetailsNoProvider = {
  id: 5,
  compute_resource_provider: null,
  reported_data: {},
};

// Host details without compute_resource_provider (for reported_data-based detection)
export const hostDetailsWithoutProvider = {
  id: 6,
  reported_data: {},
};

// Host details with reported_data containing billing data
export const hostDetailsAwsWithFacts = {
  id: 7,
  compute_resource_provider: 'ec2',
  reported_data: awsBillingDataComplete,
};

export const hostDetailsGcpWithFacts = {
  id: 8,
  compute_resource_provider: 'gce',
  reported_data: gcpBillingDataComplete,
};

export const hostDetailsAzureWithFacts = {
  id: 9,
  compute_resource_provider: 'azurerm',
  reported_data: azureBillingDataComplete,
};

