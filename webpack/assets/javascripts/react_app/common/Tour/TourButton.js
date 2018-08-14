import React from 'react';
import { Button } from 'patternfly-react';
import PropTypes from 'prop-types';
import store from '../../redux';

import { updateAsSeen } from './TourActions';
import { translate as __ } from '../I18n';
import './Tour.scss';

const TourButton = ({ id }) => (
  <Button
    className="tour-btn"
    bsStyle="primary"
    bsSize="xsmall"
    onClick={() => store.dispatch(updateAsSeen(id))}
  >
    {__('Ok, Got it')}
  </Button>
);

TourButton.propTypes = {
  id: PropTypes.string.isRequired,
};

export default TourButton;
