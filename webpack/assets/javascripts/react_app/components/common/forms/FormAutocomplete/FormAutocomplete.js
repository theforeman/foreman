import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';
import AutoComplete from '../../../AutoComplete';
import FormField from '../FormField';

const FormAutocomplete = ({
  controller,
  label,
  query,
  url,
  isDisabled,
  name,
  error,
  id,
  useKeyShortcuts,
}) => (
  <FormField
    className="form-autocomplete"
    labelSizeClass="col-md-2"
    inputSizeClass="col-md-4"
    label={label}
  >
    <AutoComplete
      id={id}
      controller={controller}
      inputProps={{ name }}
      useKeyShortcuts={useKeyShortcuts}
      isDisabled={isDisabled}
      error={error}
      searchQuery={query}
      url={url}
    />
  </FormField>
);

FormAutocomplete.propTypes = {
  controller: PropTypes.string,
  error: PropTypes.string,
  id: PropTypes.string.isRequired,
  isDisabled: PropTypes.bool,
  label: PropTypes.string,
  name: PropTypes.string,
  query: PropTypes.string,
  url: PropTypes.string,
  useKeyShortcuts: PropTypes.bool,
};

FormAutocomplete.defaultProps = {
  controller: null,
  error: null,
  isDisabled: null,
  label: __('Search'),
  name: '',
  query: '',
  url: null,
  useKeyShortcuts: false,
};

export default FormAutocomplete;
