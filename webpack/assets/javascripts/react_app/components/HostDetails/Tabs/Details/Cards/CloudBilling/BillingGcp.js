import PropTypes from 'prop-types';
import React from 'react';
import { DescriptionList } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import { propsToCamelCase } from '../../../../../../common/helpers';
import BillingDetailItem from './BillingDetailItem';

const BillingGcp = ({ data }) => {
  // Extract GCP billing facts
  const {
    gcpInstanceId,
    gcpLicenseCodes,
    gcpProjectId,
    gcpProjectNumber,
    gcpZone,
  } = propsToCamelCase(data || {});

  return (
    <DescriptionList isCompact isHorizontal>
      <BillingDetailItem label={__('GCP Instance ID')} value={gcpInstanceId} />
      <BillingDetailItem
        label={__('GCP License Code')}
        value={gcpLicenseCodes}
      />
      <BillingDetailItem label={__('GCP Project ID')} value={gcpProjectId} />
      <BillingDetailItem
        label={__('GCP Project Number')}
        value={gcpProjectNumber}
      />
      <BillingDetailItem label={__('GCP Zone')} value={gcpZone} />
    </DescriptionList>
  );
};

BillingGcp.propTypes = {
  data: PropTypes.shape({
    gcp_instance_id: PropTypes.string,
    gcp_license_codes: PropTypes.string,
    gcp_project_id: PropTypes.string,
    gcp_project_number: PropTypes.string,
    gcp_zone: PropTypes.string,
  }),
};

BillingGcp.defaultProps = {
  data: {},
};

export default BillingGcp;
