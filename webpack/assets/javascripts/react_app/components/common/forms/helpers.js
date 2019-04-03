import { noop } from '../../../common/helpers';
import { deprecate } from '../../../common/DeprecationService';

const getEventValue = ({ target: { type, checked, value } }) =>
  type === 'checkbox' ? checked : value;

export const makeOnChangeHanler = (onChange, onValueChange) => {
  if (onChange !== noop) deprecate('onChange', 'onValueChange', '1.24');

  return evt => {
    onChange(evt);
    onValueChange(getEventValue(evt));
  };
};
