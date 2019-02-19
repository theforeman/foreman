import history from '../../../history';
import API from '../../../API';
import {
  AUDITS_PAGE_FETCH,
  AUDITS_PATH,
  AUDITS_PAGE_SHOW_MESSAGE,
  AUDITS_PAGE_HIDE_MESSAGE,
  AUDITS_PAGE_SHOW_LOADING,
  AUDITS_PAGE_HIDE_LOADING,
  AUDITS_PAGE_CHANGE_PARAMS,
  AUDITS_PAGE_NEXT_PENDING,
  AUDITS_PAGE_NEXT_RESOLVED,
  AUDITS_PAGE_PREV_PENDING,
  AUDITS_PAGE_PREV_RESOLVED,
  AUDITS_PAGE_CLEAR_CACHE,
  AUDITS_NEXT,
  AUDITS_CURRENT,
  AUDITS_PREV,
} from './AuditsPageConstants';
import {
  selectNextPageAudits,
  selectPrevPageAudits,
  selectAuditsSelectedPage,
  selectAuditsShowMessage,
  selectAuditsPerPage,
  selectAuditsSearch,
  selectAuditsCount,
  selectAudits,
} from './AuditsPageSelector';
import { stringifyParams } from '../../../components/Pagination/PaginationHelper';
import { translate as __ } from '../../../common/I18n';

export const initializeAudits = (params, replace = false) => dispatch => {
  /**
   * on didMount or popstate, fetch page and page+1
   */
  dispatch(fetchAudits({ ...params, loadingBool: true }));
  dispatch(
    fetchAudits({ ...params, page: params.page + 1, view: AUDITS_NEXT })
  );
  if (replace)
    history.replace({
      pathname: AUDITS_PATH,
      search: stringifyParams(params),
    });
  dispatch({
    type: AUDITS_PAGE_CHANGE_PARAMS,
    payload: {
      ...params,
    },
  });
};

export const auditSearch = searchQuery => async (dispatch, getState) => {
  const params = {
    page: 1,
    perPage: selectAuditsPerPage(getState()),
    searchQuery,
    loadingBool: true,
  };
  dispatch(fetchAndPush(params));
};

export const changePage = page => (dispatch, getState) => {
  const state = getState();
  const perPage = selectAuditsPerPage(state);
  const searchQuery = selectAuditsSearch(state);
  const selectedPage = selectAuditsSelectedPage(state);
  const currentAudits = selectAudits(state);
  const nextPageAudits = selectNextPageAudits(state);
  const prevPageAudits = selectPrevPageAudits(state);

  const params = {
    page,
    perPage,
    searchQuery,
  };

  if (selectedPage + 1 === page && nextPageAudits.length !== 0) {
    /**
     * Next Audits are already in the store
     * if the user reduced the perPage before changing Page, the array will slice
     */
    dispatch({
      type: AUDITS_PAGE_FETCH,
      payload: {
        [AUDITS_NEXT]: [],
        [AUDITS_CURRENT]: nextPageAudits.slice(0, perPage),
        [AUDITS_PREV]: currentAudits,
        ...params,
      },
    });
    history.push({
      pathname: AUDITS_PATH,
      search: stringifyParams(params),
    });
    return dispatch(
      fetchAudits({ ...params, page: page + 1, view: AUDITS_NEXT })
    );
  }
  if (selectedPage - 1 === page && prevPageAudits.length !== 0) {
    /**
     * Previous Audits are already in the store
     * if the user reduced the perPage before changing Page, the array will slice
     */
    dispatch({
      type: AUDITS_PAGE_FETCH,
      payload: {
        [AUDITS_NEXT]: currentAudits,
        [AUDITS_CURRENT]: prevPageAudits.slice(0, perPage),
        [AUDITS_PREV]: [],
        ...params,
      },
    });
    history.push({
      pathname: AUDITS_PATH,
      search: stringifyParams(params),
    });
    if (page > 1)
      dispatch(fetchAudits({ ...params, page: page - 1, view: AUDITS_PREV }));
    return null;
  }
  // moved to a page thats not in the 'cache', so we reset it.
  dispatch(clearCache());
  dispatch(fetchAndPush({ ...params, loadingBool: true }));
  return dispatch(
    fetchAudits({ ...params, page: page + 1, view: AUDITS_NEXT })
  );
};

export const changePerPage = perPage => (dispatch, getState) => {
  const state = getState();
  const selectedPage = selectAuditsSelectedPage(state);
  const selectedPerPage = selectAuditsPerPage(state);
  const auditCount = selectAuditsCount(state);
  const params = {
    page: selectedPage,
    perPage,
    searchQuery: selectAuditsSearch(getState()),
  };

  if (perPage < selectedPerPage) {
    // slice audits, no need for API
    const audits = selectAudits(getState()).slice(0, perPage);
    history.push({
      pathname: AUDITS_PATH,
      search: stringifyParams(params),
    });
    dispatch({
      type: AUDITS_PAGE_FETCH,
      payload: {
        [AUDITS_CURRENT]: audits,
        perPage,
      },
    });
  }
  if (perPage > selectedPerPage && auditCount > selectedPerPage) {
    dispatch(fetchAndPush({ ...params, page: 1, loadingBool: true }));
    dispatch(fetchAudits({ ...params, page: 2, view: AUDITS_NEXT }));
  }
};

export const fetchAudits = ({
  page,
  perPage,
  searchQuery,
  view = AUDITS_CURRENT,
  loadingBool = false,
}) => (dispatch, getState) => {
  if (selectAuditsShowMessage(getState()))
    dispatch({
      type: AUDITS_PAGE_HIDE_MESSAGE,
    });

  const onRequestSuccess = ({ data: { audits, itemCount } }) => {
    if (loadingBool) dispatch(hideLoading());
    if (audits.length === 0 && view === AUDITS_CURRENT)
      dispatch(
        displayMessage(__('No Audits found, please search again.'), 'empty')
      );
    dispatch({
      type: AUDITS_PAGE_FETCH,
      payload: {
        [view]: audits,
        itemCount,
      },
    });
    if (view === AUDITS_NEXT) dispatch(resolvedNext());
    if (view === AUDITS_PREV) dispatch(resolvedPrev());
  };
  const onRequestFail = error => {
    if (loadingBool) dispatch(hideLoading());
    dispatch(
      displayMessage(
        __(`${error.response.status} ${error.response.statusText}`),
        'error'
      )
    );
    if (view === AUDITS_NEXT) dispatch(resolvedNext());
    if (view === AUDITS_PREV) dispatch(resolvedPrev());
  };

  if (view === AUDITS_NEXT) dispatch(fetchingNext());
  if (view === AUDITS_PREV) dispatch(fetchingPrev());
  if (loadingBool) dispatch(showLoading());
  API.get(
    AUDITS_PATH,
    {},
    {
      page,
      per_page: perPage,
      search: searchQuery,
    }
  ).then(onRequestSuccess, onRequestFail);
};

export const fetchAndPush = params => dispatch => {
  dispatch(fetchAudits(params));
  dispatch({
    type: AUDITS_PAGE_CHANGE_PARAMS,
    payload: {
      ...params,
    },
  });
  history.push({
    pathname: AUDITS_PATH,
    search: stringifyParams(params),
  });
};

export const displayMessage = (text, type) => dispatch => {
  dispatch({
    type: AUDITS_PAGE_SHOW_MESSAGE,
    payload: {
      showMessage: true,
      message: {
        text,
        type,
      },
    },
  });
};

export const showLoading = () => ({
  type: AUDITS_PAGE_SHOW_LOADING,
});

export const hideLoading = () => ({
  type: AUDITS_PAGE_HIDE_LOADING,
});

export const fetchingNext = () => ({
  type: AUDITS_PAGE_NEXT_PENDING,
});

export const fetchingPrev = () => ({
  type: AUDITS_PAGE_PREV_PENDING,
});

export const resolvedNext = () => ({
  type: AUDITS_PAGE_NEXT_RESOLVED,
});

export const resolvedPrev = () => ({
  type: AUDITS_PAGE_PREV_RESOLVED,
});

export const clearCache = () => ({
  type: AUDITS_PAGE_CLEAR_CACHE,
});
