import { API } from '../../redux/API';
import {
  GET_SETTING_REQUEST,
  GET_SETTING_SUCCESS,
  GET_SETTING_FAILURE,
} from './SettingsConstants';

export const loadSetting = (settingName) => async (dispatch) => {
  dispatch({ type: GET_SETTING_REQUEST });
  try {
    const { data } = await API.get(`/api/v2/settings/${settingName}`);
    return dispatch({
      type: GET_SETTING_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch({
      type: GET_SETTING_FAILURE,
      result: error,
    });
  }
};

export default loadSetting;
