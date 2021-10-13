import React from 'react';
import PropTypes from 'prop-types';
import { set } from 'lodash';
import { TypeAheadSelect } from 'patternfly-react';

import { noop } from '../../../../common/helpers';
import { orderDragged } from './helpers';
import { useInternalValue } from './OrderableSelectHooks';
import OrderableToken from './components/OrderableToken';

/**
 * Wraps TypeAheadSelect with an Orderable HOC.
 * Presumes to be wrapped in a DndProvider context.
 * The value can not be changed through props once the component is rendered.
 */
const OrderableSelect = ({
  className,
  onChange,
  defaultValue,
  value,
  options,
  name,
  ...props
}) => {
  const [internalValue, setInternalValue] = useInternalValue(
    value || defaultValue,
    options
  );
  const moveDraggedOption = (dragIndex, hoverIndex) => {
    setInternalValue(orderDragged(internalValue, dragIndex, hoverIndex));
  };

  // hack the form-control, which is already in TypeAhead so it would be duplicated
  const classesWithoutFormControl =
    className &&
    className
      .split(/\s+/)
      .filter((el) => el !== 'form-control')
      .join(' ');

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
          {name && <input type="hidden" name={name} value={option.value} />}
        </div>
      )}
      {...props}
      className={classesWithoutFormControl}
      options={options}
      selected={internalValue}
      onChange={(newValue) => {
        setInternalValue(newValue);
        onChange(newValue);
      }}
    />
  );
};

OrderableSelect.propTypes = {
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  id: PropTypes.string.isRequired,
  name: PropTypes.string,
  onChange: PropTypes.func,
  defaultValue: PropTypes.array,
  value: PropTypes.array,
  className: PropTypes.string,
};

OrderableSelect.defaultProps = {
  onChange: noop,
  defaultValue: [],
  value: null,
  name: null,
  className: '',
};

export default OrderableSelect;
