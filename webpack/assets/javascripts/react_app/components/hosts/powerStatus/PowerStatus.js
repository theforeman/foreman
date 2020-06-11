import React from 'react';
import PropTypes from 'prop-types';
import { simpleLoader } from '../../common/Loader';
import './PowerStatus.scss';

const PowerStatus = ({ state, title }) =>
  state ? (
    <span
      className={`fa fa-power-off host-power-status ${state}`}
      title={title}
    />
  ) : (
    simpleLoader('xs')
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
