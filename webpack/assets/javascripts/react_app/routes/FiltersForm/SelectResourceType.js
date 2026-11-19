import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { FormGroup } from '@patternfly/react-core';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { EMPTY_RESOURCE_TYPE } from './FiltersFormConstants';
import { translate as __ } from '../../common/I18n';
import { FilterTypeaheadSelect } from './FilterTypeaheadSelect';

export const SelectResourceType = ({
  type,
  setType,
  setIsGranular,
  defaultType,
  setAutocompleteQuery,
}) => {
  const apiOption = useMemo(
    () => {
      if (!defaultType) {
        return {};
      }
      return {
        handleSuccess: ({ data: { resource_types: results } }) => {
          const typeData =
            results.find(result => result.name === defaultType) ||
            EMPTY_RESOURCE_TYPE;
          setType(typeData);
          setIsGranular(typeData.granular);
        },
      };
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    []
  );
  const {
    response: { resource_types: types = [] },
  } = useAPI(
    'get',
    '/permissions/show_resource_types_with_translations',
    apiOption
  );
  const allTypes = [EMPTY_RESOURCE_TYPE, ...types];
  const onTypeSelect = typeName => {
    const selectedType = allTypes.find(option => option.name === typeName);
    setType(selectedType);
    setIsGranular(Boolean(selectedType.granular));
    setAutocompleteQuery('');
  };
  return (
    <FormGroup label={__('Resource Type')} isRequired>
      <FilterTypeaheadSelect
        ouiaId="resource-type-select"
        inputAriaLabel={__('Select a resource type')}
        toggleAriaLabel={__('Resource type toggle')}
        options={allTypes.map(option => ({
          value: option.name,
          label: option.translation,
        }))}
        selectedLabel={type.translation}
        onSelect={onTypeSelect}
      />
    </FormGroup>
  );
};

SelectResourceType.propTypes = {
  type: PropTypes.shape({
    name: PropTypes.string,
    translation: PropTypes.string,
    granular: PropTypes.bool,
    search_path: PropTypes.string,
  }).isRequired,
  setType: PropTypes.func.isRequired,
  setIsGranular: PropTypes.func.isRequired,
  defaultType: PropTypes.string,
  setAutocompleteQuery: PropTypes.func.isRequired,
};

SelectResourceType.defaultProps = {
  defaultType: '',
};
