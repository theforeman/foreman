import Immutable from 'seamless-immutable';

import { SET_UPDATE_SETTING } from './SettingsTableConstants';

const initialState = Immutable({
  toEdit: {},
});

const reducer = (state = initialState, { type, payload }) => {
  switch (type) {
    case SET_UPDATE_SETTING:
      return state.set('toEdit', payload.setting);
    default:
      return state;
  }
};

export default reducer;
