import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../../../common/helpers';
import OrderableDualListSelector from '../../OrderableDualListSelector/OrderableDualListSelector';
import {
  createInitialLists,
  chosenValues,
  normalizeSelectedValues,
} from '../../OrderableDualListSelector/helpers';

/**
 * Form input wrapper around OrderableDualListSelector for ordered multi-value fields.
 * The value can not be changed through props once the component is rendered.
 */
const OrderableDualList = ({
  id,
  name,
  options,
  value,
  defaultValue,
  disabled,
  onChange,
  availableOptionsTitle,
  chosenOptionsTitle,
}) => {
  const initialValue = normalizeSelectedValues(
    value != null && value !== '' ? value : defaultValue
  );
  const [{ available, chosen }, setLists] = useState(() =>
    createInitialLists(options, initialValue)
  );

  const handleListChange = (nextAvailable, nextChosen) => {
    setLists({ available: nextAvailable, chosen: nextChosen });
    onChange(chosenValues(nextChosen));
  };

  return (
    <>
      <OrderableDualListSelector
        id={id}
        availableOptions={available}
        chosenOptions={chosen}
        onListChange={handleListChange}
        availableOptionsTitle={availableOptionsTitle}
        chosenOptionsTitle={chosenOptionsTitle}
        isDisabled={disabled}
      />
      {name &&
        chosen.map(option => (
          <input
            key={option.value}
            type="hidden"
            name={name}
            value={option.value}
          />
        ))}
    </>
  );
};

OrderableDualList.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string,
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  value: PropTypes.array,
  defaultValue: PropTypes.array,
  disabled: PropTypes.bool,
  onChange: PropTypes.func,
  availableOptionsTitle: PropTypes.string,
  chosenOptionsTitle: PropTypes.string,
};

OrderableDualList.defaultProps = {
  name: null,
  value: null,
  defaultValue: [],
  disabled: false,
  onChange: noop,
  availableOptionsTitle: undefined,
  chosenOptionsTitle: undefined,
};

export default OrderableDualList;
