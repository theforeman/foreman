import URI from 'urijs';
import { API } from '../../../redux/API';
import { addToast } from '../../../redux/actions/toasts';
import { ajaxRequestAction } from '../../../redux/actions/common';
import { translate as __ } from '../../../common/I18n';
import {
  PERSONAL_ACCESS_TOKEN_CLEAR,
  PERSONAL_ACCESS_TOKENS_REQUEST,
  PERSONAL_ACCESS_TOKENS_SUCCESS,
  PERSONAL_ACCESS_TOKENS_FAILURE,
} from './PersonalAccessTokensConstants';

export const getPersonalAccessTokens =
  ({ url }) =>
  (dispatch) => {
    const uri = new URI(url);
    // eslint-disable-next-line camelcase
    uri.setSearch({ per_page: 9999 });

    ajaxRequestAction({
      dispatch,
      url: uri,
      requestAction: PERSONAL_ACCESS_TOKENS_REQUEST,
      successAction: PERSONAL_ACCESS_TOKENS_SUCCESS,
      failedAction: PERSONAL_ACCESS_TOKENS_FAILURE,
    });
  };

export const revokePersonalAccessToken =
  ({ url, id }) =>
  async (dispatch) => {
    try {
      await API.delete(`${url}/${id}`);
      dispatch(getPersonalAccessTokens({ url }));
      dispatch(
        addToast({
          type: 'success',
          message: __('Token was successfully revoked.'),
        })
      );
    } catch (error) {
      /* eslint-disable no-console */
      console.log(error);
      dispatch(
        addToast({
          type: 'error',
          message: __('Could not revoke Token: ') + error,
        })
      );
    }
  };

export const clearNewPersonalAccessToken = () => (dispatch) =>
  dispatch({
    type: PERSONAL_ACCESS_TOKEN_CLEAR,
    payload: {},
  });
