import PropTypes from 'prop-types';
import React from 'react';
import { DescriptionList } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import { propsToCamelCase } from '../../../../../../common/helpers';
import CloudProviderDetailItem from './CloudProviderDetailItem';

const CloudProviderAzure = ({ data }) => {
  // Extract Azure facts
  const {
    azureInstanceId,
    azureOffer,
    azureSku,
    azureSubscriptionId,
  } = propsToCamelCase(data || {});

  return (
    <DescriptionList isCompact isHorizontal>
      <CloudProviderDetailItem
        label={__('Azure Instance ID')}
        value={azureInstanceId}
      />
      <CloudProviderDetailItem label={__('Azure Offer')} value={azureOffer} />
      <CloudProviderDetailItem label={__('Azure SKU')} value={azureSku} />
      <CloudProviderDetailItem
        label={__('Azure Subscription ID')}
        value={azureSubscriptionId}
      />
    </DescriptionList>
  );
};

CloudProviderAzure.propTypes = {
  data: PropTypes.shape({
    azure_instance_id: PropTypes.string,
    azure_offer: PropTypes.string,
    azure_sku: PropTypes.string,
    azure_subscription_id: PropTypes.string,
  }),
};

CloudProviderAzure.defaultProps = {
  data: {},
};

export default CloudProviderAzure;
