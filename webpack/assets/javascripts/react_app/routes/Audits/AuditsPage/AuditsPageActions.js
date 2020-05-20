import history from '../../../history';
import { API } from '../../../redux/API';
import {
  AUDITS_PATH,
  AUDITS_PAGE_DATA_RESOLVED,
  AUDITS_PAGE_DATA_FAILED,
  AUDITS_PAGE_HIDE_LOADING,
  AUDITS_PAGE_UPDATE_QUERY,
  AUDITS_PAGE_CLEAR_ERROR,
  AUDITS_PAGE_SHOW_LOADING,
} from '../constants';
import {
  selectAuditsSelectedPage,
  selectAuditsHasError,
  selectAuditsPerPage,
  selectAuditsSearch,
  selectAuditsIsLoadingPage,
} from './AuditsPageSelectors';
import {
  foremanUrl,
  stringifyParams,
  getParams,
} from '../../../common/urlHelpers';
import { translate as __ } from '../../../common/I18n';

// on didMount or popstatee
export const initializeAudits = () => dispatch => {
  const params = getParams();
  dispatch(fetchAudits(params));
  if (!history.action === 'POP') {
    history.replace({
      pathname: foremanUrl(AUDITS_PATH),
      search: stringifyParams(params),
    });
  }
};

export const fetchAudits = (
  { page, perPage, searchQuery },
  url = foremanUrl(AUDITS_PATH)
) => async (dispatch, getState) => {
  dispatch({ type: AUDITS_PAGE_SHOW_LOADING });
  if (selectAuditsHasError(getState()))
    dispatch({
      type: AUDITS_PAGE_CLEAR_ERROR,
    });

  const onRequestSuccess = ({ data: { audits, itemCount } }) => {
    if (selectAuditsIsLoadingPage(getState()))
      dispatch({ type: AUDITS_PAGE_HIDE_LOADING });

    dispatch({
      type: AUDITS_PAGE_UPDATE_QUERY,
      payload: {
        page,
        perPage,
        searchQuery,
        itemCount,
      },
    });

    dispatch({
      type: AUDITS_PAGE_DATA_RESOLVED,
      payload: {
        audits,
        hasData: itemCount > 0,
      },
    });
  };
  const onRequestFail = error => {
    if (selectAuditsIsLoadingPage(getState()))
      dispatch({ type: AUDITS_PAGE_HIDE_LOADING });

    dispatch({
      type: AUDITS_PAGE_DATA_FAILED,
      payload: {
        message: {
          type: 'error',
          text: `${error.response.status} ${__(error.response.statusText)}`,
        },
      },
    });
  };
  try {
    const response = await API.get(
      url,
      {},
      {
        page,
        per_page: perPage,
        search: searchQuery,
      }
    );
    return onRequestSuccess(response);
  } catch (error) {
    return onRequestFail(error);
  }
};

export const fetchAndPush = params => (dispatch, getState) => {
  const query = buildQuery(params, getState());
  dispatch(fetchAudits(query));
  history.push({
    pathname: foremanUrl(AUDITS_PATH),
    search: stringifyParams(query),
  });
};

const buildQuery = (query, state) => ({
  page: query.page || selectAuditsSelectedPage(state),
  perPage: query.perPage || selectAuditsPerPage(state),
  searchQuery:
    query.searchQuery === undefined
      ? selectAuditsSearch(state)
      : query.searchQuery,
});
