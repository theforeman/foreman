import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { actionButtonPropTypes } from './EmptyStatePropTypes';

const SecondaryActionButtons = ({ actions }) =>
  actions.map(({ title, url }) => (
    <Button key={`sec-button-${title}`} url={url}>
      {title}
    </Button>
  ));

SecondaryActionButtons.propTypes = {
  actions: PropTypes.arrayOf(PropTypes.shape(actionButtonPropTypes)),
};

SecondaryActionButtons.defaultProps = {
  actions: [],
};

export default SecondaryActionButtons;
