import React from 'react';

const NotificationDrawerTitle = ({text}) => (
  <div className="drawer-pf-title">
    <a className="drawer-pf-toggle-expand"></a>
    <h3 className="text-center">{text}</h3>
  </div>
);

export default NotificationDrawerTitle;
