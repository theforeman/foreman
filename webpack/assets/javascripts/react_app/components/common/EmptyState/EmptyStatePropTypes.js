import PropTypes from 'prop-types';

export const actionButtonPropTypes = {
  title: PropTypes.node.isRequired,
  url: PropTypes.string,
  onChange: PropTypes.func,
};

export const emptyStatePatternPropTypes = {
  icon: PropTypes.string.isRequired,
  header: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  documentation: PropTypes.node,
  action: PropTypes.node,
  secondaryActions: PropTypes.node,
};

export const defaultEmptyStatePropTypes = {
  ...emptyStatePatternPropTypes,
  icon: PropTypes.string,
  documentation: PropTypes.shape({
    label: PropTypes.string,
    buttonLabel: PropTypes.string,
    url: PropTypes.string.isRequired,
  }),
  action: PropTypes.shape(actionButtonPropTypes),
  secondaryActions: PropTypes.arrayOf(PropTypes.shape(actionButtonPropTypes)),
};
