import Immutable from 'seamless-immutable';

import {
  LOAD_SETTING_RECORDS,
  SET_EDITING_SETTING,
  SETTINGS_FORM_SUBMITTED,
} from './SettingRecordsConstants';

export const initialState = Immutable({
  settings: {},
  editing: null,
});

const reducer = (state = initialState, { type, payload }) => {
  switch (type) {
    case LOAD_SETTING_RECORDS:
      return state.set('settings', payload);
    case SETTINGS_FORM_SUBMITTED: {
      const updatedSetting = payload.data;
      const categorized = state.settings[updatedSetting.category];
      const updatedCategory = categorized.map(item =>
        item.id === updatedSetting.id ? updatedSetting : item
      );
      return state.setIn(
        ['settings', updatedSetting.category],
        updatedCategory
      );
    }
    case SET_EDITING_SETTING:
      return state.set('editing', payload.setting);
    default:
      return state;
  }
};

export default reducer;
