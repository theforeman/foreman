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
}) => dispatch => {
  startRequest({
    controller,
    searchQuery,
    trigger,
    dispatch,
  });

  const path = getAPIPath({ trigger, searchQuery, url });
  return createAPIRequest({
    controller,
    path,
    searchQuery,
    trigger,
    dispatch,
  });
};

let createAPIRequest = ({ controller, path, searchQuery, trigger, dispatch }) =>
  API.get(path)
    .then(({ data }) =>
      requestSuccess({
        data,
        controller,
        dispatch,
        searchQuery,
        trigger,
      })
    )
    .catch(error => requestFailure({ error, dispatch }));

createAPIRequest = debounce(createAPIRequest, 250);

const startRequest = ({ controller, searchQuery, trigger, dispatch }) => {
  dispatch({
    type: AUTO_COMPLETE_REQUEST,
    payload: {
      controller,
      searchQuery,
      status: STATUS.PENDING,
      trigger,
    },
  });
};

const requestSuccess = ({
  data,
  trigger,
  controller,
  searchQuery,
  dispatch,
}) => {
  const { error } = data[0] || {};
  if (error) {
    throw error;
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
    },
  });
};

const requestFailure = ({ error, dispatch }) =>
  dispatch({
    type: AUTO_COMPLETE_FAILURE,
    payload: {
      results: [],
      error: error.message || error,
      status: STATUS.ERROR,
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

export const resetData = controller => dispatch =>
  dispatch({
    type: AUTO_COMPLETE_RESET,
    payload: { controller },
    error: null,
  });

export const initialUpdate = (searchQuery, controller) => dispatch =>
  dispatch({
    type: AUTO_COMPLETE_SUCCESS,
    payload: {
      searchQuery,
      controller,
      trigger: TRIGGERS.COMPONENT_DID_MOUNT,
      status: STATUS.RESOLVED,
      results: [],
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
