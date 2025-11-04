import PropTypes from 'prop-types';
import React from 'react';
import { translate as __ } from '../../../../../../common/I18n';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import CloudProviderAws from './CloudProviderAws';
import CloudProviderAzure from './CloudProviderAzure';
import CloudProviderGcp from './CloudProviderGcp';

// Helper function to map cloud provider to provider code
const getProviderCode = cloudProvider => {
  /* eslint-disable spellcheck/spell-checker */
  switch (cloudProvider) {
    case 'aws':
    case 'ec2':
      return 'ec2';
    case 'azure':
    case 'azurerm':
      return 'azurerm';
    case 'gcp':
    case 'gce':
      return 'gce';
    default:
      return null;
  }
  /* eslint-enable spellcheck/spell-checker */
};

// Helper function to get provider-specific header
const getProviderHeader = provider => {
  /* eslint-disable spellcheck/spell-checker */
  switch (provider) {
    case 'ec2':
      return __('AWS details');
    case 'azurerm':
      return __('Azure details');
    case 'gce':
      return __('GCP details');
    default:
      return __('Cloud provider details');
  }
  /* eslint-enable spellcheck/spell-checker */
};

// Provider field mappings
/* eslint-disable spellcheck/spell-checker */
const PROVIDER_FIELDS = {
  ec2: [
    'aws_account_id',
    'aws_billing_products',
    'aws_instance_id',
    'aws_instance_type',
    'aws_marketplace_product_codes',
    'aws_region',
  ],
  azurerm: [
    'azure_instance_id',
    'azure_offer',
    'azure_sku',
    'azure_subscription_id',
  ],
  gce: [
    'gcp_instance_id',
    'gcp_license_codes',
    'gcp_project_id',
    'gcp_project_number',
    'gcp_zone',
  ],
};
/* eslint-enable spellcheck/spell-checker */

// Helper function to check if provider has any data
const hasProviderData = (provider, data) => {
  if (!data) return false;

  /* eslint-disable spellcheck/spell-checker */
  const fields = PROVIDER_FIELDS[provider] || [];
  /* eslint-enable spellcheck/spell-checker */

  return fields.some(field => data[field]);
};

// Helper function to detect provider from reported data
const detectProviderFromData = data => {
  if (!data) return null;

  // Check each provider to see if it has any data
  /* eslint-disable spellcheck/spell-checker */
  const providers = ['ec2', 'azurerm', 'gce'];
  return providers.find(provider => hasProviderData(provider, data)) || null;
  /* eslint-enable spellcheck/spell-checker */
};

const CloudProviderCard = ({ hostDetails }) => {
  const {
    compute_resource_provider: computeResourceProvider,
    reported_data: reportedData,
  } = hostDetails;

  // Early return if no reported_data available
  if (!reportedData || Object.keys(reportedData).length === 0) return null;

  // Map of cloud providers to their component
  const cloudProviders = {
    ec2: CloudProviderAws,
    azurerm: CloudProviderAzure,
    gce: CloudProviderGcp,
  };

  // Determine provider with multiple fallbacks:
  // 1. First check if cloud_provider is set in reported_data
  // 2. Then check compute_resource_provider
  // 3. Finally, detect from the actual billing data present
  const cloudProvider = reportedData.cloud_provider || computeResourceProvider;
  let provider = getProviderCode(cloudProvider);

  // If no provider identified yet, try to detect from data
  if (!provider) {
    provider = detectProviderFromData(reportedData);
  }

  // Only show for cloud providers with actual data
  if (!provider || !cloudProviders[provider]) return null;

  // Get the appropriate provider component
  const CloudProviderComponent = cloudProviders[provider];

  return (
    <CardTemplate header={getProviderHeader(provider)} expandable masonryLayout>
      <CloudProviderComponent data={reportedData} provider={provider} />
    </CardTemplate>
  );
};

CloudProviderCard.propTypes = {
  hostDetails: PropTypes.shape({
    compute_resource_provider: PropTypes.string,
    reported_data: PropTypes.shape({
      cloud_provider: PropTypes.string,
      // AWS facts
      aws_account_id: PropTypes.string,
      aws_billing_products: PropTypes.string,
      aws_instance_id: PropTypes.string,
      aws_instance_type: PropTypes.string,
      aws_marketplace_product_codes: PropTypes.string,
      aws_region: PropTypes.string,
      // Azure facts
      azure_instance_id: PropTypes.string,
      azure_offer: PropTypes.string,
      azure_sku: PropTypes.string,
      azure_subscription_id: PropTypes.string,
      // GCP facts
      gcp_instance_id: PropTypes.string,
      gcp_license_codes: PropTypes.string,
      gcp_project_id: PropTypes.string,
      gcp_project_number: PropTypes.string,
      gcp_zone: PropTypes.string,
    }),
  }),
};

CloudProviderCard.defaultProps = {
  hostDetails: {},
};

export default CloudProviderCard;
