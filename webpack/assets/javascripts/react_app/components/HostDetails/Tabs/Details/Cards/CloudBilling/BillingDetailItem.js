import PropTypes from 'prop-types';
import React from 'react';
import {
  DescriptionListTerm as Dt,
  DescriptionListGroup,
  DescriptionListDescription as Dd,
} from '@patternfly/react-core';

const BillingDetailItem = ({ label, value }) => {
  if (value === null || value === undefined || value === '') return null;

  return (
    <DescriptionListGroup>
      <Dt>{label}</Dt>
      <Dd>{value}</Dd>
    </DescriptionListGroup>
  );
};

BillingDetailItem.propTypes = {
  label: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
};

BillingDetailItem.defaultProps = {
  value: undefined,
};

export default BillingDetailItem;
