import React from 'react';
import AutoCompleteClearButton from './AutoCompleteClearButton';

const AutoCompleteAux = ({ onClear, clearTooltipID }) => (
  <div className="autocomplete-aux">
    <AutoCompleteClearButton onClear={onClear} tooltipID={clearTooltipID} />
  </div>
);

AutoCompleteAux.propTypes = {
  ...AutoCompleteClearButton.propTypes,
};

AutoCompleteAux.defaultProps = {
  ...AutoCompleteClearButton.defaultProps,
};

export default AutoCompleteAux;
