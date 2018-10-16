import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { actionButtonPropTypes } from './EmptyStatePropTypes';

const PrimaryActionButton = ({ action }) => {
  if (!action) {
    return null;
  }

  if (action.url) {
    return urlButton(action);
  }

  if (action.onClick) {
    return onClickButton(action);
  }

  throw new Error(
    'Primary action button expects action with either url or onClick'
  );
};

// eslint-disable-next-line react/prop-types
const urlButton = ({ url, title }) => (
  <Button href={url} bsStyle="primary" bsSize="large">
    {title}
  </Button>
);

// eslint-disable-next-line react/prop-types
const onClickButton = ({ onClick, title }) => (
  <Button onClick={onClick} bsStyle="primary" bsSize="large">
    {title}
  </Button>
);

PrimaryActionButton.propTypes = {
  action: PropTypes.shape(actionButtonPropTypes).isRequired,
};

export default PrimaryActionButton;
