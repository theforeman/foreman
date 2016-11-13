import React from 'react';
import Loader from '../common/Loader';
import './PowerStatus.css';

const PowerStatus = ({ state, loadingStatus, title, statusText }) => {
  const icon = (
    <span
      key="0"
      className={'fa fa-power-off host-power-status ' + state}
      title={statusText || title} />
  );

  const error = (
    <span
      key="1"
      className="fa fa-power-off host-power-status na"
      title={title + ' ' + statusText}/>
  );

  return (
    <Loader status={loadingStatus} spinnerSize="xs">
      {[icon, error]}
    </Loader>
  );
};

export default PowerStatus;
