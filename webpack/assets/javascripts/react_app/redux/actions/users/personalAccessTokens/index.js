import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON,
  USERS_PERSONAL_ACCESS_GET_REQUEST,
  USERS_PERSONAL_ACCESS_GET_SUCCESS,
  USERS_PERSONAL_ACCESS_GET_FAILURE
} from '../../../consts';
import { ajaxRequestAction } from '../../common';
import API from '../../../../API';
import { addToast } from '../../toasts';

export const showForm = personalAccessToken => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
    payload: {}
  };
};

export const hideForm = () => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON,
    payload: {}
  };
};

export const getTokens = userId => dispatch =>
  ajaxRequestAction({
    dispatch,
    requestAction: USERS_PERSONAL_ACCESS_GET_REQUEST,
    successAction: USERS_PERSONAL_ACCESS_GET_SUCCESS,
    failedAction: USERS_PERSONAL_ACCESS_GET_FAILURE,
    url: `/api/users/${userId}/personal_access_tokens?per_page=9999`,
    item: { userId }
  });

export const revokeToken = (userId, tokenId) => dispatch => {
  API.delete(`/api/users/${userId}/personal_access_tokens/${tokenId}`).then(() => {
    getTokens(userId)(dispatch);
  }).then(() =>
    dispatch(
      addToast({
        type: 'success',
        message: __('Token was successfully revoked.')
      })
    )
  ).catch((result) => {
    /* eslint-disable no-console */
    console.log(result);
    dispatch(
      addToast({
        type: 'error',
        // eslint-disable-next-line no-undef
        message: Jed.sprintf('Could not revoke Token: %s', result.statusText)
      })
    );
  });
};
