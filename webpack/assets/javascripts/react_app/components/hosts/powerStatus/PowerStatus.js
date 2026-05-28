import React from 'react';
import PropTypes from 'prop-types';
import { Spinner } from '@patternfly/react-core';
import './PowerStatus.scss';

const PowerStatus = ({ state, title }) =>
  state ? (
    <span
      className={`fa fa-power-off host-power-status ${state}`}
      title={title}
    />
  ) : (
    <Spinner size="sm" aria-label="Loading" isInline />
  );

PowerStatus.propTypes = {
  state: PropTypes.string,
  title: PropTypes.string,
};

PowerStatus.defaultProps = {
  state: '',
  title: '',
};

export default PowerStatus;
