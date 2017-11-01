import React from 'react';
import getIconClass from './Icon.consts';

export default ({ className = '', type }) => (
  <span
    className={`${getIconClass(type)}${className ? ' ' + className : ''}`}
  />
);
