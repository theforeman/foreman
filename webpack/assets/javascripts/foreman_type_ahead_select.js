import {
  updateOptions as updateTypeAheadSelectOptions,
  updateSelected as updateTypeAheadSelectSelected,
} from './react_app/components/common/TypeAheadSelect/TypeAheadSelectActions';
import store from './react_app/redux';

export const updateOptions = (options, id) => {
  store.dispatch(updateTypeAheadSelectOptions(options, id));
};

export const updateSelected = (selected, id) => {
  store.dispatch(updateTypeAheadSelectSelected(selected, id));
};
