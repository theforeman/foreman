import PropTypes from 'prop-types';

export const actionButtonPropTypes = {
  title: PropTypes.node.isRequired,
  url: PropTypes.string,
  onChange: PropTypes.func,
};

export const emptyStatePatternPropTypes = {
  icon: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
  header: PropTypes.string.isRequired,
  documentation: PropTypes.oneOfType([
    PropTypes.shape({
      label: PropTypes.string,
      buttonLabel: PropTypes.string,
      url: PropTypes.string.isRequired,
    }),
    PropTypes.node,
  ]),
  description: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
  action: PropTypes.node,
  secondaryActions: PropTypes.node,
  variant: PropTypes.oneOf(['xs', 'sm', 'lg', 'xl', 'full']),
};

export const defaultEmptyStatePropTypes = {
  ...emptyStatePatternPropTypes,
  action: PropTypes.shape(actionButtonPropTypes),
  secondaryActions: PropTypes.arrayOf(PropTypes.shape(actionButtonPropTypes)),
};

export const footerActionPropTypes = {
  label: PropTypes.node.isRequired,
  onClick: PropTypes.func,
  url: PropTypes.string,
  ouiaId: PropTypes.string,
};

export const resourceLoadFailedEmptyStatePropTypes = {
  resourceLabel: PropTypes.string.isRequired,
  resourceId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  header: PropTypes.string,
  description: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
  errorMessage: PropTypes.string,
  /** HTTP status from the failed load request (e.g. axios error.response.status). */
  httpStatus: PropTypes.number,
  /** Permissions required to view the resource; used with usePermissions and httpStatus. */
  viewPermissions: PropTypes.arrayOf(PropTypes.string),
  /** Optional page-level permissions shown as documentation when load did not fail for access. */
  requiredPermissions: PropTypes.arrayOf(PropTypes.string),
  primaryAction: PropTypes.shape(footerActionPropTypes).isRequired,
  secondaryActions: PropTypes.arrayOf(PropTypes.shape(footerActionPropTypes)),
  showBackButton: PropTypes.bool,
  backButtonLabel: PropTypes.string,
  icon: PropTypes.node,
  variant: PropTypes.oneOf(['xs', 'sm', 'lg', 'xl', 'full']),
  ouiaIdPrefix: PropTypes.string,
};
