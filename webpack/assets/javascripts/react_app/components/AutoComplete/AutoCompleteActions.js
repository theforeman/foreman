import URI from 'urijs';
import debounce from 'lodash/debounce';
import API from '../../API';
import { STATUS } from '../../constants';
import { clearSpaces } from '../../common/helpers';
import { translate as __ } from '../../common/I18n';
import {
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
  AUTO_COMPLETE_DISABLED_CHANGE,
  TRIGGERS,
  ERROR_TO_SHOW,
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
    url,
    id,
  });
  return createAPIRequest({
    controller,
    searchQuery,
    trigger,
    url,
    dispatch,
    id,
  });
};

let createAPIRequest = ({
  controller,
  searchQuery,
  trigger,
  url,
  dispatch,
  id,
}) => {
  if (!url) {
    requestFailure({ error: '', id, dispatch });
    throw new Error(__('No API path was provided.'));
  }
  const path = getAPIPath({ trigger, searchQuery, url });
  return API.get(path)
    .then(({ data }) =>
      requestSuccess({
        data,
        controller,
        dispatch,
        searchQuery,
        trigger,
        url,
        id,
      })
    )
    .catch(error => {
      const { type } = error;
      if (type !== ERROR_TO_SHOW) {
        requestFailure({ error: '', id, dispatch });
        throw error;
      }
      requestFailure({ error: error.message, id, dispatch });
    });
};

createAPIRequest = debounce(createAPIRequest, 250);

const startRequest = ({
  controller,
  searchQuery,
  trigger,
  dispatch,
  url,
  id,
}) => {
  dispatch({
    type: AUTO_COMPLETE_REQUEST,
    payload: {
      controller,
      searchQuery,
      status: STATUS.PENDING,
      trigger,
      url,
      id,
    },
  });
};

const requestSuccess = ({
  data,
  trigger,
  controller,
  searchQuery,
  dispatch,
  url,
  id,
}) => {
  const { error } = data[0] || {};
  if (error) {
    // eslint-disable-next-line no-throw-literal
    throw { message: error, type: ERROR_TO_SHOW };
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
      url,
      id,
    },
  });
};

const requestFailure = ({ error, id, dispatch }) =>
  dispatch({
    type: AUTO_COMPLETE_FAILURE,
    payload: {
      results: [],
      error: error.message || error,
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

export const resetData = ({ controller, id }) => ({
  type: AUTO_COMPLETE_RESET,
  payload: {
    trigger: TRIGGERS.RESET,
    controller,
    id,
  },
});

export const initialUpdate = ({
  searchQuery,
  controller,
  url,
  isDisabled,
  id,
  error,
}) => ({
  type: AUTO_COMPLETE_SUCCESS,
  payload: {
    searchQuery,
    controller,
    trigger: TRIGGERS.COMPONENT_DID_MOUNT,
    status: STATUS.RESOLVED,
    results: [],
    url,
    isDisabled,
    id,
    error,
  },
});

export const updateDisability = (isDisabled, id) => ({
  type: AUTO_COMPLETE_DISABLED_CHANGE,
  payload: {
    isDisabled,
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
