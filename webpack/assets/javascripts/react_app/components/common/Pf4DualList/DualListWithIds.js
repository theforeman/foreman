import React, { useState, useMemo } from 'react';
import PropTypes from 'prop-types';
import { Pf4DualList } from './index';
import { useAPI } from '../../../common/hooks/API/APIHooks';

export const DualListWithIds = ({
  url,
  setChosenIds,
  defaultValue,
  ...props
}) => {
  const [availableOptions, setAvailableOptions] = useState([]);
  const [chosenOptions, setChosenOptions] = useState([]);
  const [nameToId, setNameToId] = useState({});
  const apiOptions = useMemo(
    () => ({
      handleSuccess: ({ data: { results } }) => {
        const options = results.map(result => result.name);
        if (defaultValue.length && options.includes(defaultValue[0].name)) {
          const defaultValueNames = defaultValue.map(d => d.name);
          setChosenIds(defaultValue.map(d => d.id));
          setChosenOptions(defaultValueNames);
          setAvailableOptions(
            options.filter(option => !defaultValueNames.includes(option))
          );
        } else {
          setAvailableOptions(options);
          setChosenIds([]);
          setChosenOptions([]);
        }
        const newNameToId = {};
        results.forEach(result => {
          newNameToId[result.name] = result.id;
        });
        setNameToId(newNameToId);
      },
    }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    []
  );
  useAPI('get', url, apiOptions);
  const onListChange = (newAvailableOptions, newChosenOptions) => {
    setAvailableOptions(newAvailableOptions.sort());
    setChosenOptions(newChosenOptions.sort());
    setChosenIds(newChosenOptions.map(option => nameToId[option]));
  };
  return (
    <Pf4DualList
      isSearchable
      availableOptions={availableOptions}
      chosenOptions={chosenOptions}
      onListChange={onListChange}
      {...props}
    />
  );
};

DualListWithIds.propTypes = {
  defaultValue: PropTypes.array,
  url: PropTypes.string.isRequired,
  setChosenIds: PropTypes.func.isRequired,
};

DualListWithIds.defaultProps = {
  defaultValue: [],
};
