import React from 'react';

const PanelHeading = props => (
  <div
    className={'panel-heading ' + (props.className ? props.className : '')}
    onClick={props.onClick}
    data-toggle="tooltip"
    title={props.title}
  >
    {props.children}
  </div>
);

export default PanelHeading;
