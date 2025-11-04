import PropTypes from 'prop-types';
import React from 'react';
import { DescriptionList } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import { propsToCamelCase } from '../../../../../../common/helpers';
import CloudProviderDetailItem from './CloudProviderDetailItem';

const CloudProviderAws = ({ data }) => {
  // Extract AWS facts
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
      <CloudProviderDetailItem
        label={__('AWS Account ID')}
        value={awsAccountId}
      />
      <CloudProviderDetailItem
        label={__('AWS Billing Product')}
        value={awsBillingProducts}
      />
      <CloudProviderDetailItem
        label={__('AWS Instance ID')}
        value={awsInstanceId}
      />
      <CloudProviderDetailItem
        label={__('AWS Instance Type')}
        value={awsInstanceType}
      />
      <CloudProviderDetailItem
        label={__('AWS Marketplace Product')}
        value={awsMarketplaceProducts}
      />
      <CloudProviderDetailItem label={__('AWS Region')} value={awsRegion} />
    </DescriptionList>
  );
};

CloudProviderAws.propTypes = {
  data: PropTypes.shape({
    aws_account_id: PropTypes.string,
    aws_billing_products: PropTypes.string,
    aws_instance_id: PropTypes.string,
    aws_instance_type: PropTypes.string,
    aws_marketplace_product_codes: PropTypes.string,
    aws_region: PropTypes.string,
  }),
};

CloudProviderAws.defaultProps = {
  data: {},
};

export default CloudProviderAws;
