import React from 'react';
import { DualListSelector } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';

export const Pf4DualList = props => (
  <DualListSelector
    availableOptionsTitle={__('Available options')}
    chosenOptionsTitle={__('Chosen options')}
    {...props}
  />
);
