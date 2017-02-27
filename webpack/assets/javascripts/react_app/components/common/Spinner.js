import React, { PropTypes } from 'react';

const Spinner = ({size, inline, inverse}) => {
  const css = `spinner spinner-${size} ` +
    (inline ? ' spinner-inline ' : '') + (inverse ? ' spinner-inverse ' : '');

  return (
    <div className={css} >
    </div>
  );
};

Spinner.propTypes = {
  inline: PropTypes.bool,
  inverse: PropTypes.bool,
  size: PropTypes.oneOf(['lg', 'sm', 'xs'])
};

Spinner.defaultProps = {
  size: 'lg',
  inline: false,
  inverse: false
};

export default Spinner;
