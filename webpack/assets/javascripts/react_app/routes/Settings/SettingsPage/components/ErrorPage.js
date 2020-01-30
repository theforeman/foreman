import React from 'react';
import PropTypes from 'prop-types';
import { EmptyStatePattern as EmptyState } from '../../../../components/common/EmptyState';

const ErrorPage = ({ errorMsg }) => (
  <EmptyState
    iconType="pf"
    icon="error-circle-o"
    header={errorMsg.type}
    description={errorMsg.text}
  />
);

ErrorPage.propTypes = {
  errorMsg: PropTypes.object.isRequired,
};

export default ErrorPage;
