import { API_OPERATIONS } from '../../../redux/consts';

import {
  STATISTICS_PAGE_DATA_RESOLVED,
  STATISTICS_PAGE_DATA_FAILED,
  STATISTICS_PAGE_HIDE_LOADING,
  STATISTICS_PAGE_URL,
} from '../constants';

export const getStatisticsMeta = (
  url = STATISTICS_PAGE_URL
) => async dispatch => {
  const formatResults = data => ({
    metadata: data,
    hasData: data.length > 0,
  });
  const formatErrors = ({ error }) => ({
    message: {
      type: 'error',
      text: error.message,
    },
  });
  dispatch({
    type: API_OPERATIONS.GET,
    outputType: 'STATISTICS_PAGE',
    actionTypes: {
      SUCCESS: STATISTICS_PAGE_DATA_RESOLVED,
      FAILURE: STATISTICS_PAGE_DATA_FAILED,
    },
    url,
    onSuccess: () => dispatch(hideLoading()),
    onFailure: () => dispatch(hideLoading()),
    successFormat: formatResults,
    errorFormat: formatErrors,
  });
};

const hideLoading = () => ({
  type: STATISTICS_PAGE_HIDE_LOADING,
});
