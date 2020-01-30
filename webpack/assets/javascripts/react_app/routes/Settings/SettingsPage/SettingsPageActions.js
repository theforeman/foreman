import URI from 'urijs';

import history from '../../../history';
import { API } from '../../../redux/API';

import { deepPropsToCamelCase } from '../../../common/helpers';

import {
  SETTINGS_PAGE_DATA_RESOLVED,
  SETTINGS_PAGE_DATA_FAILED,
  SETTINGS_PAGE_CLEAR_ERROR,
  SETTINGS_PAGE_SHOW_LOADING,
  SETTINGS_API_PATH,
  SETTINGS_PATH,
} from '../constants';

import { selectHasError } from './SettingsPageSelectors';

export const initializeSettings = initialParams => dispatch => {
  dispatch(fetchSettings(initialParams));

  if (!history.action === 'POP') {
    history.replace({
      pathname: SETTINGS_PATH,
      search: URI()
        .search(initialParams)
        .query(),
    });
  }
};

const transformParams = params => ({ search: params.search });

export const fetchSettings = (params, url = SETTINGS_API_PATH) => async (
  dispatch,
  getState
) => {
  dispatch({ type: SETTINGS_PAGE_SHOW_LOADING });

  if (selectHasError(getState())) {
    dispatch({ type: SETTINGS_PAGE_CLEAR_ERROR });
  }

  try {
    const { data } = await API.get(url, {}, transformParams(params));

    const transformedResponse = deepPropsToCamelCase(data);

    dispatch({
      type: SETTINGS_PAGE_DATA_RESOLVED,
      payload: {
        ...transformedResponse,
        hasData: transformedResponse.subtotal > 0,
        isLoading: false,
      },
    });
  } catch (error) {
    const { response } = error;
    let baseType = response.status;
    let baseText = response.statusText;
    if (response && response.data) {
      const { type, text } = response.data;
      baseType = type || baseType;
      baseText = text || baseText;
    }
    dispatch({
      type: SETTINGS_PAGE_DATA_FAILED,
      payload: {
        message: {
          type: baseType,
          text: baseText,
        },
        isLoading: false,
      },
    });
  }
};

export const fetchAndPush = params => (dispatch, getState) => {
  const query = buildQuery(params);
  dispatch(fetchSettings(query));
  history.push({
    pathname: SETTINGS_PATH,
    search: URI()
      .search(query)
      .query(),
  });
};

const buildQuery = params => (params.search ? params : {});
