import React from 'react';
import Icon from './Icon';

const CloseButton = ({onClick}) => {
  return (
    <button className="close" aria-hidden="true" onClick={onClick}>
      <Icon type="close" />
    </button>
  );
};

CloseButton.propTypes = {
  onClick: React.PropTypes.func.isRequired
};

export default CloseButton;
