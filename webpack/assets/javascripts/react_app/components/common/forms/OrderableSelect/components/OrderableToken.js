import React from 'react';
import PropTypes from 'prop-types';
import { TypeAheadSelect } from 'patternfly-react';

import { orderable } from '../helpers';

const orderConfig = {
  type: 'multiValue',
  getItem: (props) => ({ value: props.data.value }),
  getIndex: (props) => props.data.index,
  getMoveFnc: (props) => props.moveDraggedOption,
};

const OrderableToken = ({
  isDragging,
  moveDraggedOption,
  data,
  disabled,
  onRemove,
  tabIndex,
  labelKey,
}) => (
  <TypeAheadSelect.Token
    disabled={disabled}
    onRemove={onRemove}
    tabIndex={tabIndex}
  >
    {data[labelKey]}
  </TypeAheadSelect.Token>
);

OrderableToken.propTypes = {
  isDragging: PropTypes.bool.isRequired,
  moveDraggedOption: PropTypes.func.isRequired,
  data: PropTypes.object.isRequired,
  labelKey: PropTypes.string.isRequired,
  disabled: PropTypes.bool,
  tabIndex: PropTypes.number,
  onRemove: PropTypes.func,
};

OrderableToken.defaultProps = {
  disabled: false,
  tabIndex: -1,
  onRemove: undefined,
};

export default orderable(OrderableToken, orderConfig);
