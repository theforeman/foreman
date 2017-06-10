import React from 'react';
import { SimpleLoader } from '../../../common/Loader';
import './PowerStatusInner.scss';

export default ({ state, title, statusText, error }) => {
  if (error) {
    return (
      <span
        className="fa fa-power-off host-power-status na"
        title={title + ' ' + statusText}
      />
    );
  }
  if (!state) {
    return <SimpleLoader size="xs" />;
  }
  return (
    <span
      className={`fa fa-power-off host-power-status ${state}`}
      title={statusText || title}
    />
  );
};
