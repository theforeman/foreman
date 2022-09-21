import React, { useState, useMemo } from 'react';
import PropTypes from 'prop-types';
import {
  Select,
  SelectOption,
  SelectVariant,
  FormGroup,
} from '@patternfly/react-core';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { EMPTY_RESOURCE_TYPE } from './FiltersFormConstants';
import { translate as __ } from '../../common/I18n';

export const SelectResourceType = ({
  type,
  setType,
  setIsGranular,
  defaultType,
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
  const [isOpen, setIsOpen] = useState(false);
  return (
    <FormGroup label={__('Resource Type')} isRequired>
      <Select
        className="without_select2"
        maxHeight="45vh"
        variant={SelectVariant.typeahead}
        typeAheadAriaLabel="Select a resource type"
        onToggle={setIsOpen}
        selections={type.translation}
        isOpen={isOpen}
        aria-labelledby="resource type"
        onSelect={() => {
          setIsOpen(false);
        }}
        toggleAriaLabel="resource type toggle"
      >
        {[
          <SelectOption
            onClick={() => {
              setType(EMPTY_RESOURCE_TYPE);
              setIsGranular(false);
            }}
            key={EMPTY_RESOURCE_TYPE.name}
            value={EMPTY_RESOURCE_TYPE.translation}
          />,
          ...types.map(option => (
            <SelectOption
              onClick={() => {
                setType(option);
                setIsGranular(option.granular);
              }}
              key={option.name}
              value={option.translation}
            />
          )),
        ]}
      </Select>
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
};

SelectResourceType.defaultProps = {
  defaultType: '',
};
