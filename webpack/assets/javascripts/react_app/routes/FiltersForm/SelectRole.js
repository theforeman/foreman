import React from 'react';
import PropTypes from 'prop-types';
import { FormGroup } from '@patternfly/react-core';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { translate as __ } from '../../common/I18n';
import { FilterTypeaheadSelect } from './FilterTypeaheadSelect';

export const SelectRole = ({ role, setRole }) => {
  const {
    response: { results = [] },
  } = useAPI('get', '/api/v2/roles?per_page=all&search=locked=false');
  return (
    <FormGroup label={__('Role')} isRequired>
      <FilterTypeaheadSelect
        ouiaId="select-role"
        inputAriaLabel={__('Select a role')}
        toggleAriaLabel={__('Role toggle')}
        options={results.map(result => ({
          value: result.id,
          label: result.name,
        }))}
        selectedLabel={results.find(result => result.id === role)?.name}
        onSelect={setRole}
      />
    </FormGroup>
  );
};

SelectRole.propTypes = {
  role: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  setRole: PropTypes.func.isRequired,
};
