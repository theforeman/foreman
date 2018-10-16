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
  title: PropTypes.string,
  state: PropTypes.string,
  statusText: PropTypes.string,
  error: PropTypes.string,
};

PowerStatusInner.defaultProps = {
  title: '',
  state: null,
  statusText: null,
  error: null,
};

export default PowerStatusInner;
