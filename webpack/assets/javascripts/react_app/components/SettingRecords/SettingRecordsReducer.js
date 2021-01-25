import Immutable from 'seamless-immutable';

import {
  LOAD_SETTING_RECORDS,
  SET_EDITING_SETTING,
  SETTINGS_FORM_SUBMITTED_SUCCESS,
} from './SettingRecordsConstants';

export const initialState = Immutable({
  settings: {},
  editing: null,
});

const reducer = (state = initialState, { type, payload, response }) => {
  switch (type) {
    case LOAD_SETTING_RECORDS:
      return state.set('settings', payload);
    case SETTINGS_FORM_SUBMITTED_SUCCESS: {
      const categorized = state.settings[response.category];
      const updatedCategory = categorized.map(item =>
        item.name === response.id ? { ...item, value: response.value } : item
      );
      return state.setIn(['settings', response.category], updatedCategory);
    }
    case SET_EDITING_SETTING:
      return state.set('editing', payload.setting);
    default:
      return state;
  }
};

export default reducer;
