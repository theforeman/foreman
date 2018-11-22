import React from 'react';
import PropTypes from 'prop-types';
import './Story.scss';

const Story = ({ narrow, children }) => {
  const classes = `story ${narrow ? 'narrow' : ''}`;

  return (
    <div className={classes}>
      {children}
    </div>
  );
};

Story.propTypes = {
  narrow: PropTypes.bool,
};

Story.defaultProps = {
  narrow: false,
};

export default Story;
