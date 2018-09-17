import React from 'react';
import PropTypes from 'prop-types';
import { simpleLoader } from '../../../common/Loader';
import './PowerStatusInner.scss';

const PowerStatusInner = ({ state, title, statusText, error }) => {
  if (error) {
    return (
      <span
        className="fa fa-power-off host-power-status na"
        title={`${title} ${statusText}`}
      />
    );
  }
  if (!state) {
    return simpleLoader('xs');
  }
  return (
    <span
      className={`fa fa-power-off host-power-status ${state}`}
      title={statusText || title}
    />
  );
};

PowerStatusInner.propTypes = {
  state: PropTypes.string,
  title: PropTypes.string,
  statusText: PropTypes.string,
  error: PropTypes.bool,
};

PowerStatusInner.defaultProps = {
  state: null,
  title: null,
  statusText: null,
  error: false,
};

export default PowerStatusInner;
