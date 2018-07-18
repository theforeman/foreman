import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { actionButtonPropTypes } from './EmptyStatePropTypes';

const PrimaryActionButton = ({ action: { title, url } }) => (
  <Button url={url} bsStyle="primary" bsSize="large">
    {title}
  </Button>
);

PrimaryActionButton.propTypes = {
  action: PropTypes.shape(actionButtonPropTypes),
};

export default PrimaryActionButton;
