import API from '../../API';
import {
  GET_SETTING_REQUEST,
  GET_SETTING_SUCCESS,
  GET_SETTING_FAILURE,
} from './SettingsConstants';

export const loadSetting = settingName => dispatch => {
  dispatch({ type: GET_SETTING_REQUEST });

  return API.get(`/api/v2/settings/${settingName}`)
    .then(({ data }) => {
      dispatch({
        type: GET_SETTING_SUCCESS,
        response: data,
      });
    })
    .catch(result => {
      dispatch({
        type: GET_SETTING_FAILURE,
        result,
      });
    });
};

export default loadSetting;
