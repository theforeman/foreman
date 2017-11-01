import React from 'react';

const PanelBody = ({ children, className }) => (
  <div className={'panel-body ' + (className ? className : '')}>{children}</div>
);

export default PanelBody;
