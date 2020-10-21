import { REGISTER_FILL, REMOVE_FILLED_COMPONENT } from './FillConstants';
import { add, remove } from '../../../../services/SlotsRegistry';

export const registerFillComponent = (
  slotId,
  overrideProps,
  fillId,
  component,
  weight
) => dispatch => {
  add(slotId, fillId, component, weight, overrideProps);
  dispatch({
    type: REGISTER_FILL,
    payload: { slotId, fillId, weight },
  });
};

export const unregisterFillComponent = (slotId, fillId) => dispatch => {
  remove(slotId, fillId);
  dispatch({
    type: REMOVE_FILLED_COMPONENT,
    payload: { slotId },
  });
};
