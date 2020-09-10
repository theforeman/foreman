import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

const LayoutContainer = ({ isCollapsed, children }) => {
  const classes = classNames(
    'react-container container-fluid nav-pf-persistent-secondary',
    {
      'collapsed-nav': isCollapsed,
    }
  );
  return <div className={classes}>{children}</div>;
};

LayoutContainer.propTypes = {
  isCollapsed: PropTypes.bool.isRequired,
  children: PropTypes.node,
};

LayoutContainer.defaultProps = {
  children: null,
};

export default LayoutContainer;
