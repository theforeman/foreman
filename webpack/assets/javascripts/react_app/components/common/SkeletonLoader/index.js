import React from 'react';
import PropTypes from 'prop-types';
import Skeleton from 'react-loading-skeleton';

import { STATUS } from '../../../constants';
import { translate as __ } from '../../../common/I18n';

const SkeletonLoader = ({
  status,
  customSkeleton,
  skeletonProps,
  emptyState,
  children,
  errorNode,
}) => {
  switch (status) {
    case STATUS.PENDING: {
      return customSkeleton || <Skeleton {...skeletonProps} />;
    }
    case STATUS.RESOLVED: {
      return children || emptyState;
    }
    case STATUS.ERROR: {
      return errorNode || emptyState;
    }
    default:
      return emptyState;
  }
};

SkeletonLoader.propTypes = {
  status: PropTypes.string.isRequired,
  customSkeleton: PropTypes.node,
  skeletonProps: PropTypes.object,
  emptyState: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
  children: PropTypes.node,
  errorNode: PropTypes.node,
};

SkeletonLoader.defaultProps = {
  customSkeleton: undefined,
  skeletonProps: {},
  emptyState: __('N/A'),
  children: undefined,
  errorNode: undefined,
};
export default SkeletonLoader;
