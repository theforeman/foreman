import URI from 'urijs';
import debounce from 'lodash/debounce';
import API from '../../API';
import { STATUS } from '../../constants';
import { clearSpaces } from '../../common/helpers';
import {
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
  TRIGGERS,
} from './AutoCompleteConstants';

export const getResults = ({
  url,
  searchQuery,
  controller,
  trigger,
  id,
}) => dispatch => {
  startRequest({
    controller,
    searchQuery,
    trigger,
    dispatch,
    id,
  });

  return createAPIRequest({
    controller,
    searchQuery,
    trigger,
    id,
    dispatch,
    url,
  });
};

let createAPIRequest = async ({
  controller,
  searchQuery,
  trigger,
  id,
  dispatch,
  url,
}) => {
  if (!url) {
    return requestFailure({
      error: new Error('No API path was provided.'),
      id,
      dispatch,
      isVisible: false,
    });
  }
  try {
    const path = getAPIPath({ trigger, searchQuery, url });
    const { data } = await API.get(path);

    return requestSuccess({
      data,
      controller,
      dispatch,
      searchQuery,
      trigger,
      id,
    });
  } catch (error) {
    return requestFailure({
      error,
      id,
      dispatch,
      isVisible: error.message === 'Network Error',
    });
  }
};

createAPIRequest = debounce(createAPIRequest, 250);

const startRequest = ({ controller, searchQuery, trigger, dispatch, id }) => {
  dispatch({
    type: AUTO_COMPLETE_REQUEST,
    payload: {
      controller,
      searchQuery,
      status: STATUS.PENDING,
      trigger,
      id,
    },
  });
};

const requestSuccess = ({
  data,
  trigger,
  controller,
  searchQuery,
  id,
  dispatch,
}) => {
  const { error } = data[0] || {};
  if (error) {
    return requestFailure({ error: new Error(error), id, dispatch });
  }
  if (!Array.isArray(data)) {
    const noDataError = new Error(
      `Response data is not an array, instead received: ${JSON.stringify(data)}`
    );
    return requestFailure({
      error: noDataError,
      id,
      dispatch,
      isVisible: false,
    });
  }
  const results = data.map(result => objectDeepTrim(result, trigger));
  return dispatch({
    type: AUTO_COMPLETE_SUCCESS,
    payload: {
      controller,
      results,
      searchQuery,
      status: STATUS.RESOLVED,
      trigger,
      id,
    },
  });
};

const requestFailure = ({ error, id, dispatch, isVisible = true }) => {
  dispatch({
    type: AUTO_COMPLETE_FAILURE,
    payload: {
      results: [],
      error: error.message,
      isErrorVisible: isVisible,
      status: STATUS.ERROR,
      id,
    },
  });
};

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

export const resetData = (controller, id) => dispatch =>
  dispatch({
    type: AUTO_COMPLETE_RESET,
    payload: { controller, id },
  });

export const initialUpdate = ({
  searchQuery,
  controller,
  error,
  id,
}) => dispatch =>
  dispatch({
    type: AUTO_COMPLETE_SUCCESS,
    payload: {
      searchQuery,
      controller,
      trigger: TRIGGERS.COMPONENT_DID_MOUNT,
      status: STATUS.RESOLVED,
      results: [],
      error,
      isErrorVisible: !!error,
      id,
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
