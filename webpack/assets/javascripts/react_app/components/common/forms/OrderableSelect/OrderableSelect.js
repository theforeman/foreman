import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { set } from 'lodash';
import { TypeAheadSelect } from 'patternfly-react';

import { noop } from '../../../../common/helpers';
import { orderDragged } from './helpers';
import OrderableToken from './components/OrderableToken';

/**
 * Wraps TypeAheadSelect with an Orderable HOC.
 * Presumes to be wrapped in a DndProvider context.
 */
const OrderableSelect = ({
  onChange,
  defaultValue,
  value,
  options,
  ...props
}) => {
  const [internalValue, setInternalValue] = useState(
    (value || defaultValue)
      .map(v => options.find(opt => opt.value === v))
      .filter(v => !!v)
  );
  const moveDraggedOption = (dragIndex, hoverIndex) => {
    setInternalValue(orderDragged(internalValue, dragIndex, hoverIndex));
  };

  return (
    <TypeAheadSelect
      multiple
      renderToken={(option, tokenProps, idx) => (
        <div
          id={`${props.id || 'selectValue'}-${option.value}`}
          style={{ display: 'inline-block' }}
          key={option.value}
        >
          <OrderableToken
            data={set(option, 'index', idx)}
            moveDraggedOption={moveDraggedOption}
            {...tokenProps}
          />
        </div>
      )}
      {...props}
      options={options}
      selected={internalValue}
      onChange={newValue => {
        setInternalValue(newValue);
        onChange(newValue);
      }}
    />
  );
};

OrderableSelect.propTypes = {
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  id: PropTypes.string.isRequired,
  onChange: PropTypes.func,
  defaultValue: PropTypes.array,
  value: PropTypes.array,
};

OrderableSelect.defaultProps = {
  onChange: noop,
  defaultValue: [],
  value: null,
};

export default OrderableSelect;
