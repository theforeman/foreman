import { DUAL_LIST_INIT, DUAL_LIST_CHANGE } from './DualListConstants';

export const initialUpdate = (selectedItems, id) => ({
  type: DUAL_LIST_INIT,
  payload: {
    selectedItems,
    id,
  },
});

export const onChange = (selectedItems, id) => ({
  type: DUAL_LIST_CHANGE,
  payload: {
    selectedItems,
    id,
  },
});
