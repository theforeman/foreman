import React from 'react';
import { MenuItem } from 'patternfly-react';
import Icon from '../Icon';

export default ({ href, id = 'documentationLink' }) => {
  const handleClick = (e) => {
    e.preventDefault();
    window.open(href, '_blank');
  };

  return (
    <MenuItem key="documentationUrl" id={id} href={href} onClick={handleClick}>
      <Icon type="question-sign" className="icon-black" />
      {` ${__('Documentation')}`}
    </MenuItem>
  );
};
