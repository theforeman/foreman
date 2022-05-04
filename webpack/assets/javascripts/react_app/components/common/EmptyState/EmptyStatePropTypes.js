import PropTypes from 'prop-types';

export const actionButtonPropTypes = {
  title: PropTypes.node.isRequired,
  url: PropTypes.string,
  onChange: PropTypes.func,
};

export const emptyStatePatternPropTypes = {
  icon: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
  iconType: PropTypes.string,
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
};

export const defaultEmptyStatePropTypes = {
  ...emptyStatePatternPropTypes,
  action: PropTypes.shape(actionButtonPropTypes),
  secondaryActions: PropTypes.arrayOf(PropTypes.shape(actionButtonPropTypes)),
};
