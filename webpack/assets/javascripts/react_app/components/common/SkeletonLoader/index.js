import React from 'react';
import PropTypes from 'prop-types';
import Skeleton from 'react-loading-skeleton';
import { translate as __ } from '../../../../react_app/common/I18n';

const SkeletonLoader = ({ isLoading, skeletonProps, emptyState }) => {
  if (isLoading) {
    return <Skeleton {...skeletonProps} />;
  }
  return emptyState;
};

SkeletonLoader.propTypes = {
  isLoading: PropTypes.bool.isRequired,
  skeletonProps: PropTypes.object,
  emptyState: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
};

SkeletonLoader.defaultProps = {
  skeletonProps: {},
  emptyState: __('N/A'),
};
export default SkeletonLoader;
