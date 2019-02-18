import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import './Story.scss';

const Story = ({ narrow, children }) => {
  const classes = `story ${narrow ? 'narrow' : ''}`;

  return <div className={classes}>{children}</div>;
};

Story.propTypes = {
  narrow: PropTypes.bool,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

Story.defaultProps = {
  narrow: false,
  children: null,
};

export default Story;
