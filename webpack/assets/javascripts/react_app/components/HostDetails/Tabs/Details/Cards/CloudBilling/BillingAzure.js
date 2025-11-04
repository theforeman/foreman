import PropTypes from 'prop-types';
import React from 'react';
import { DescriptionList } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import { propsToCamelCase } from '../../../../../../common/helpers';
import BillingDetailItem from './BillingDetailItem';

const BillingAzure = ({ data }) => {
  // Extract Azure billing facts
  const {
    azureInstanceId,
    azureOffer,
    azureSku,
    azureSubscriptionId,
  } = propsToCamelCase(data || {});

  return (
    <DescriptionList isCompact isHorizontal>
      <BillingDetailItem
        label={__('Azure Instance ID')}
        value={azureInstanceId}
      />
      <BillingDetailItem label={__('Azure Offer')} value={azureOffer} />
      <BillingDetailItem label={__('Azure SKU')} value={azureSku} />
      <BillingDetailItem
        label={__('Azure Subscription ID')}
        value={azureSubscriptionId}
      />
    </DescriptionList>
  );
};

BillingAzure.propTypes = {
  data: PropTypes.shape({
    azure_instance_id: PropTypes.string,
    azure_offer: PropTypes.string,
    azure_sku: PropTypes.string,
    azure_subscription_id: PropTypes.string,
  }),
};

BillingAzure.defaultProps = {
  data: {},
};

export default BillingAzure;
