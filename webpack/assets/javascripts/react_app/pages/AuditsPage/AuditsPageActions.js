import API from '../../API';
import {
  AUDITS_PAGE_FETCH,
  AUDITS_PATH,
  AUDITS_PAGE_SHOW_MESSAGE,
  AUDITS_PAGE_HIDE_MESSAGE,
} from './AuditsPageConstants';
import { selectAuditsShowMessage } from './AuditsPageSelector';
import { getURI } from '../../components/Pagination/PaginationHelper';
import { showLoading, hideLoading } from '../../../foreman_navigation';
import { translate as __ } from '../../common/I18n';

export const fetchAudits = ({
  page = 1,
  perPage = 20,
  searchQuery = '',
  historyPush = true,
  historyReplace = false,
} = {}) => (dispatch, getState) => {
  showLoading();
  if (selectAuditsShowMessage(getState()))
    dispatch({
      type: AUDITS_PAGE_HIDE_MESSAGE,
    });
  API.get(
    AUDITS_PATH,
    {},
    {
      page,
      per_page: perPage,
      search: searchQuery,
    }
  ).then(
    ({ data: { audits, itemCount } }) => {
      if (audits.length === 0)
        dispatch({
          type: AUDITS_PAGE_SHOW_MESSAGE,
          payload: {
            showMessage: true,
            message: {
              text: __('No Audits found, please search again.'),
              type: 'empty',
            },
          },
        });
      hideLoading();
      const uri = getURI();
      if (historyPush) {
        uri.setQuery({
          page,
          per_page: perPage,
        });
        if (searchQuery !== '') uri.setQuery({ search: searchQuery });
        else uri.removeQuery('search');
        if (historyReplace)
          window.history.replaceState('audits', '', uri.toString());
        else window.history.pushState('audits', '', uri.toString());
      }
      dispatch({
        type: AUDITS_PAGE_FETCH,
        payload: {
          audits,
          page,
          perPage,
          itemCount,
          searchQuery,
        },
      });
    },
    error => {
      hideLoading();
      dispatch({
        type: AUDITS_PAGE_SHOW_MESSAGE,
        payload: {
          showMessage: true,
          message: {
            text: __(`${error.response.status} ${error.response.statusText}`),
            type: 'error',
          },
        },
      });
    }
  );
};
