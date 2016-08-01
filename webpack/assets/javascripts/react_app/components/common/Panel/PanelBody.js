import React from 'react';

const PanelBody = ({children, style}) =>
  (
    <div className="panel-body" style={style}>
      {children}
    </div>
  );

export default PanelBody;
