import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { FormGroup } from '@patternfly/react-core';
import {
  Select,
  SelectOption,
  SelectVariant,
} from '@patternfly/react-core/deprecated';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { translate as __ } from '../../common/I18n';

export const SelectRole = ({ role, setRole }) => {
  const {
    response: { results = [] },
  } = useAPI('get', '/api/v2/roles?per_page=all&search=locked=false');
  const [isOpen, setIsOpen] = useState(false);
  return (
    <FormGroup label={__('Role')} isRequired>
      <Select
        ouiaId="select-role"
        className="without_select2"
        maxHeight="45vh"
        variant={SelectVariant.typeahead}
        typeAheadAriaLabel="Select a role"
        onToggle={(_event, val) => setIsOpen(val)}
        selections={results.find(result => result.id === role)?.name}
        isOpen={isOpen}
        aria-labelledby="resource type"
        onSelect={() => {
          setIsOpen(false);
        }}
      >
        {results.map(option => (
          <SelectOption
            onClick={() => {
              setRole(option.id);
            }}
            key={option.id}
            value={option.name}
          />
        ))}
      </Select>
    </FormGroup>
  );
};

SelectRole.propTypes = {
  role: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  setRole: PropTypes.func.isRequired,
};
