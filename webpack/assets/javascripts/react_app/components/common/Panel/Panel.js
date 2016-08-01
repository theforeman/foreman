import React from 'react';

const Panel = (props) => {
  const type = props.type || 'default';

  return (
    <div className={'panel panel-' + type} style={props.style}>
      {props.children}
    </div>
  );
};

export default Panel;
