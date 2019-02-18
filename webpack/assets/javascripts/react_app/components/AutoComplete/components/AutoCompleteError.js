import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';

const AutoCompleteError = ({ error }) => (
  <div className="autocomplete-error">{error}</div>
);

AutoCompleteError.propTypes = {
  error: PropTypes.string,
};

AutoCompleteError.defaultProps = {
  error: null,
};

export default AutoCompleteError;
