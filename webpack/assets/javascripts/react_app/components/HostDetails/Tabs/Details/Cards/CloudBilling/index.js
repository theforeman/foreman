import PropTypes from 'prop-types';
import React from 'react';
import { translate as __ } from '../../../../../../common/I18n';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import BillingAws from './BillingAws';
import BillingAzure from './BillingAzure';
import BillingGcp from './BillingGcp';

// Helper function to detect provider from billing facts
// Uses representative facts to determine the cloud provider
const detectProviderFromFacts = data => {
  if (!data) return null;

  /* eslint-disable spellcheck/spell-checker */
  if (data.aws_account_id) return 'ec2';
  if (data.gcp_project_id) return 'gce';
  if (data.azure_subscription_id) return 'azurerm';
  /* eslint-enable spellcheck/spell-checker */

  return null;
};

// Helper function to check if provider has any billing data
const hasBillingData = (provider, data) => {
  if (!data) return false;

  /* eslint-disable spellcheck/spell-checker */
  const billingFields = {
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

  const fields = billingFields[provider] || [];
  return fields.some(field => data[field]);
};

const CloudBillingCard = ({ hostDetails }) => {
  const {
    compute_resource_provider: provider,
    reported_data: reportedData,
  } = hostDetails;

  // Early return if no reported_data available
  if (!reportedData || Object.keys(reportedData).length === 0) return null;

  // Map of cloud providers to their component
  const cloudProviders = {
    ec2: BillingAws,
    azurerm: BillingAzure,
    gce: BillingGcp,
  };

  // Determine provider: use compute_resource_provider if available,
  // otherwise detect from reported_data
  const detectedProvider = provider || detectProviderFromFacts(reportedData);

  // Only show for cloud providers
  if (!detectedProvider || !cloudProviders[detectedProvider]) return null;

  // Check if we have any billing data for this provider
  if (!hasBillingData(detectedProvider, reportedData)) return null;

  // Get the appropriate billing component
  const BillingComponent = cloudProviders[detectedProvider];

  return (
    <CardTemplate header={__('Cloud billing details')} expandable masonryLayout>
      <BillingComponent data={reportedData} provider={detectedProvider} />
    </CardTemplate>
  );
};

CloudBillingCard.propTypes = {
  hostDetails: PropTypes.shape({
    compute_resource_provider: PropTypes.string,
    reported_data: PropTypes.shape({
      // AWS billing facts
      aws_account_id: PropTypes.string,
      aws_billing_products: PropTypes.string,
      aws_instance_id: PropTypes.string,
      aws_instance_type: PropTypes.string,
      aws_marketplace_product_codes: PropTypes.string,
      aws_region: PropTypes.string,
      // Azure billing facts
      azure_instance_id: PropTypes.string,
      azure_offer: PropTypes.string,
      azure_sku: PropTypes.string,
      azure_subscription_id: PropTypes.string,
      // GCP billing facts
      gcp_instance_id: PropTypes.string,
      gcp_license_codes: PropTypes.string,
      gcp_project_id: PropTypes.string,
      gcp_project_number: PropTypes.string,
      gcp_zone: PropTypes.string,
    }),
  }),
};

CloudBillingCard.defaultProps = {
  hostDetails: {},
};

export default CloudBillingCard;
