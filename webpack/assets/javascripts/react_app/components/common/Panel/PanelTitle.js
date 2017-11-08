import React from 'react';

const PanelTitle = ({ text, className }) => (
  <h3 className={'panel-title ' + (className ? className : '')}>{text}</h3>
);

export default PanelTitle;
