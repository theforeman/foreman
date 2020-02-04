import {
  INIT,
  UPDATE_OPTIONS,
  UPDATE_SELECTED,
} from './TypeAheadSelectConstants';
import { mapSelected } from './TypeAheadSelectSelectors';

export const initialUpdate = (options, selected, id) => ({
  type: INIT,
  payload: {
    id,
    options,
    selected,
  },
});

export const updateOptions = (options, id) => ({
  type: UPDATE_OPTIONS,
  payload: {
    id,
    options,
  },
});

export const updateSelected = (selected, id) => ({
  type: UPDATE_SELECTED,
  payload: {
    id,
    selected: mapSelected(selected),
  },
});
