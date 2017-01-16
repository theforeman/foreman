import React from 'react';
import {ICON_CSS} from '../../constants';

const Icon = (props) => {
  const classNames = props.css ? ICON_CSS[props.type] + ' ' + props.css : ICON_CSS[props.type];

  return (
    <span className={classNames}></span>
  );
};

export default Icon;
