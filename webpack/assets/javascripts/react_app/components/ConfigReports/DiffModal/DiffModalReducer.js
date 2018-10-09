import Immutable from 'seamless-immutable';
import {
  DIFF_MODAL_TOGGLE,
  DIFF_MODAL_CREATE,
  DIFF_MODAL_VIEWTYPE,
} from './DiffModalConstants';

const initialState = Immutable({
  isOpen: false,
  diff: '',
  title: '',
  diffViewType: 'split',
});

export default (state = initialState, action) => {
  switch (action.type) {
    case DIFF_MODAL_TOGGLE:
      return state.set('isOpen', !state.isOpen);
    case DIFF_MODAL_VIEWTYPE:
      return state.set('diffViewType', action.payload.diffViewType);
    case DIFF_MODAL_CREATE:
      return state.merge(action.payload);

    default:
      return state;
  }
};
