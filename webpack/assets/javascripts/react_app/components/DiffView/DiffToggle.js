import React from 'react';
import PropTypes from 'prop-types';
import { ToggleGroup, ToggleGroupItem } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import { SPLIT, UNIFIED } from './DiffConsts';

const DiffToggle = ({ stateView, changeState }) => {
  const handleItemClick = (isSelected, viewType) =>
    isSelected && changeState(viewType);

  return (
    <ToggleGroup id="diff-toggle-buttons" aria-label="editor-diff-buttons">
      <ToggleGroupItem
        key={`${SPLIT}-btn`}
        text={__('Split')}
        buttonId={`${SPLIT}-btn`}
        className="diff-button"
        isSelected={stateView === SPLIT}
        onChange={selected => handleItemClick(selected, SPLIT)}
      />
      <ToggleGroupItem
        key={`${UNIFIED}-btn`}
        text={__('Unified')}
        buttonId={`${UNIFIED}-btn`}
        className="diff-button"
        isSelected={stateView === UNIFIED}
        onChange={selected => handleItemClick(selected, UNIFIED)}
      />
    </ToggleGroup>
  );
};

DiffToggle.propTypes = {
  stateView: PropTypes.string.isRequired,
  changeState: PropTypes.func.isRequired,
};

export default DiffToggle;
