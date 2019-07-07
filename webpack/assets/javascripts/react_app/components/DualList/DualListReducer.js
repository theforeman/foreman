import Immutable from 'seamless-immutable';
import { DUAL_LIST_INIT, DUAL_LIST_CHANGE } from './DualListConstants';

export default (state = Immutable({}), action) => {
  const { type, payload: { selectedItems, id } = {} } = action;
  switch (type) {
    case DUAL_LIST_INIT:
      return state.setIn([id], {
        selectedItems,
      });
    case DUAL_LIST_CHANGE:
      return state.setIn([id], {
        selectedItems,
      });
    default:
      return state;
  }
};
