import URI from 'urijs';
import { debounce } from 'lodash';
import { API } from '../../redux/API';
import { STATUS } from '../../constants';
import { clearSpaces } from '../../common/helpers';
import {
  AUTO_COMPLETE_INIT,
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
  AUTO_COMPLETE_DISABLED_CHANGE,
  AUTO_COMPLETE_CONTROLLER_CHANGE,
  TRIGGERS,
} from './AutoCompleteConstants';

export const getResults = ({
  url,
  searchQuery,
  controller,
  trigger,
  id,
}) => dispatch => {
  dispatch(
    startRequest({
      controller,
      searchQuery,
      trigger,
      dispatch,
      id,
      url,
    })
  );

  return createAPIRequest({
    searchQuery,
    trigger,
    id,
    dispatch,
    url,
  });
};

let createAPIRequest = async ({ searchQuery, trigger, id, dispatch, url }) => {
  if (!url) {
    return dispatch(
      requestFailure({
        error: new Error('No API path was provided.'),
        id,
        dispatch,
        isVisible: false,
      })
    );
  }
  try {
    const path = getAPIPath({ trigger, searchQuery, url });
    const { data } = await API.get(path);

    return dispatch(
      requestSuccess({
        data,
        dispatch,
        trigger,
        id,
      })
    );
  } catch (error) {
    return dispatch(
      requestFailure({
        error,
        id,
        dispatch,
        isVisible: error.message === 'Network Error',
      })
    );
  }
};

createAPIRequest = debounce(createAPIRequest, 250);

const startRequest = ({ controller, searchQuery, trigger, id, url }) => ({
  type: AUTO_COMPLETE_REQUEST,
  payload: {
    controller,
    searchQuery,
    status: STATUS.PENDING,
    trigger,
    error: null,
    id,
    url,
  },
});

const requestSuccess = ({ data, trigger, id }) => {
  const { error } = data[0] || {};
  if (error) {
    return requestFailure({ error: new Error(error), id });
  }
  if (!Array.isArray(data)) {
    const noDataError = new Error(
      `Response data is not an array, instead received: ${JSON.stringify(data)}`
    );
    return requestFailure({
      error: noDataError,
      id,
      isVisible: false,
    });
  }
  const results = data.map(result => objectDeepTrim(result, trigger));
  return {
    type: AUTO_COMPLETE_SUCCESS,
    payload: {
      results,
      status: STATUS.RESOLVED,
      id,
    },
  };
};

const requestFailure = ({ error, id, isVisible = true }) => ({
  type: AUTO_COMPLETE_FAILURE,
  payload: {
    results: [],
    error: error.message,
    isErrorVisible: isVisible,
    status: STATUS.ERROR,
    id,
  },
});

const isFinishedWithPoint = string => string.slice(-1) === '.';

const getAPIPath = ({ trigger, searchQuery, url }) => {
  const loadNextResults =
    trigger === TRIGGERS.ITEM_SELECT && !isFinishedWithPoint(searchQuery)
      ? ' '
      : '';
  const APISearchQuery = searchQuery + loadNextResults;
  const APIPath = new URI(url);
  APIPath.addSearch({ search: APISearchQuery });
  return APIPath.toString();
};

export const resetData = (controller, id) => ({
  type: AUTO_COMPLETE_RESET,
  payload: { controller, id },
});

export const initialUpdate = ({
  searchQuery,
  controller,
  error,
  id,
  url,
  disabled,
}) => ({
  type: AUTO_COMPLETE_INIT,
  payload: {
    searchQuery,
    controller,
    trigger: TRIGGERS.COMPONENT_DID_MOUNT,
    status: STATUS.RESOLVED,
    error,
    isErrorVisible: !!error,
    id,
    disabled,
    url,
  },
});

const objectDeepTrim = (obj, trigger) => {
  const copy = { ...obj };
  Object.keys(copy).forEach(key => {
    const addSpace =
      key === 'label' && trigger === TRIGGERS.ITEM_SELECT ? ' ' : '';
    copy[key] = clearSpaces(copy[key]) + addSpace;
  });
  return copy;
};

export const updateDisability = (disabled, id) => ({
  type: AUTO_COMPLETE_DISABLED_CHANGE,
  payload: {
    disabled,
    id,
  },
});

export const updateController = (controller, url, id) => ({
  type: AUTO_COMPLETE_CONTROLLER_CHANGE,
  payload: {
    controller,
    url,
    trigger: TRIGGERS.CONTROLLER_CHANGED,
    id,
  },
});
