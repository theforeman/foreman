import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

const LayoutContainer = ({ isCollapsed, children }) => {
  const classes = 'react-container container-fluid nav-pf-persistent-secondary';

  useEffect(() => {
    if (isCollapsed) document.body.classList.add('collapsed-nav');
    else document.body.classList.remove('collapsed-nav');
  }, [isCollapsed]);
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
