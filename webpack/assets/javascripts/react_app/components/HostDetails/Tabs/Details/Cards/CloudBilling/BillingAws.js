import PropTypes from 'prop-types';
import React from 'react';
import { DescriptionList } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import { propsToCamelCase } from '../../../../../../common/helpers';
import BillingDetailItem from './BillingDetailItem';

const BillingAws = ({ data }) => {
  // Extract AWS billing facts
  const {
    awsAccountId,
    awsBillingProducts,
    awsInstanceId,
    awsInstanceType,
    awsMarketplaceProductCodes: awsMarketplaceProducts,
    awsRegion,
  } = propsToCamelCase(data || {});

  return (
    <DescriptionList isCompact isHorizontal>
      <BillingDetailItem label={__('AWS Account ID')} value={awsAccountId} />
      <BillingDetailItem
        label={__('AWS Billing Product')}
        value={awsBillingProducts}
      />
      <BillingDetailItem label={__('AWS Instance ID')} value={awsInstanceId} />
      <BillingDetailItem
        label={__('AWS Instance Type')}
        value={awsInstanceType}
      />
      <BillingDetailItem
        label={__('AWS Marketplace Product')}
        value={awsMarketplaceProducts}
      />
      <BillingDetailItem label={__('AWS Region')} value={awsRegion} />
    </DescriptionList>
  );
};

BillingAws.propTypes = {
  data: PropTypes.shape({
    aws_account_id: PropTypes.string,
    aws_billing_products: PropTypes.string,
    aws_instance_id: PropTypes.string,
    aws_instance_type: PropTypes.string,
    aws_marketplace_product_codes: PropTypes.string,
    aws_region: PropTypes.string,
  }),
};

BillingAws.defaultProps = {
  data: {},
};

export default BillingAws;
