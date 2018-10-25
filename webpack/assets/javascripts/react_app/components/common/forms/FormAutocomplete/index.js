import React from 'react';
import PropTypes from 'prop-types';
import { FormGroup, Col, ControlLabel } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';
import AutoComplete from '../../../AutoComplete';

const FormAutocomplete = ({
  controller,
  label,
  initialQuery,
  useKeyShortcuts,
  url,
  isDisabled,
  name,
  initialError,
  id,
}) => (
  <FormGroup className="form-autocomplete">
    <Col componentClass={ControlLabel} md={2}>
      {label}
    </Col>
    <Col md={4}>
      <AutoComplete
        id={id}
        controller={controller}
        initialQuery={initialQuery}
        useKeyShortcuts={useKeyShortcuts}
        initialUrl={url}
        initialDisabled={isDisabled}
        inputProps={{ name }}
        initialError={initialError}
      />
    </Col>
  </FormGroup>
);

FormAutocomplete.propTypes = {
  url: PropTypes.string,
  useKeyShortcuts: PropTypes.bool,
  isDisabled: PropTypes.bool,
  controller: PropTypes.string,
  initialQuery: PropTypes.string,
  initialError: PropTypes.string,
  label: PropTypes.string,
  name: PropTypes.string,
  id: PropTypes.string,
};

FormAutocomplete.defaultProps = {
  url: null,
  useKeyShortcuts: false,
  isDisabled: null,
  controller: null,
  initialQuery: '',
  label: __('Search'),
  name: '',
  initialError: null,
  id: 'form-autocomplete',
};

export default FormAutocomplete;
