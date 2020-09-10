import React from 'react';
import AutoCompleteClearButton from './AutoCompleteClearButton';

const AutoCompleteAux = ({ ...props }) => (
  <div className="autocomplete-aux">
    <AutoCompleteClearButton {...props} />
  </div>
);

AutoCompleteAux.propTypes = {
  ...AutoCompleteClearButton.propTypes,
};

AutoCompleteAux.defaultProps = {
  ...AutoCompleteClearButton.defaultProps,
};

export default AutoCompleteAux;
