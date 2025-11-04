import PropTypes from 'prop-types';
import React from 'react';
import { DescriptionList } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../common/I18n';
import { propsToCamelCase } from '../../../../../../common/helpers';
import CloudProviderDetailItem from './CloudProviderDetailItem';

const CloudProviderGcp = ({ data }) => {
  // Extract GCP facts
  const {
    gcpInstanceId,
    gcpLicenseCodes,
    gcpProjectId,
    gcpProjectNumber,
    gcpZone,
  } = propsToCamelCase(data || {});

  return (
    <DescriptionList isCompact isHorizontal>
      <CloudProviderDetailItem
        label={__('GCP Instance ID')}
        value={gcpInstanceId}
      />
      <CloudProviderDetailItem
        label={__('GCP License Code')}
        value={gcpLicenseCodes}
      />
      <CloudProviderDetailItem
        label={__('GCP Project ID')}
        value={gcpProjectId}
      />
      <CloudProviderDetailItem
        label={__('GCP Project Number')}
        value={gcpProjectNumber}
      />
      <CloudProviderDetailItem label={__('GCP Zone')} value={gcpZone} />
    </DescriptionList>
  );
};

CloudProviderGcp.propTypes = {
  data: PropTypes.shape({
    gcp_instance_id: PropTypes.string,
    gcp_license_codes: PropTypes.string,
    gcp_project_id: PropTypes.string,
    gcp_project_number: PropTypes.string,
    gcp_zone: PropTypes.string,
  }),
};

CloudProviderGcp.defaultProps = {
  data: {},
};

export default CloudProviderGcp;
