import React from 'react';

const PanelHeading = (props) =>
  (
    <div className="panel-heading"
         onClick={props.onClick}
         data-toggle="tooltip"
         title={props.title} style={props.style}>
      {props.children}
    </div>
  );

export default PanelHeading;
