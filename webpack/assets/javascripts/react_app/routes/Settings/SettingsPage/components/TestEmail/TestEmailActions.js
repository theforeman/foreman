import { API } from '../../../../../redux/API';

import { addToast } from '../../../../../redux/actions/toasts';

import {
  TEST_EMAIL_REQUEST,
  TEST_EMAIL_RESPONSE,
  TEST_EMAIL_URL,
} from './TestEmailConstants';

export const testEmail = currentUserId => async dispatch => {
  dispatch({ type: TEST_EMAIL_REQUEST });

  const url = TEST_EMAIL_URL.replace(':id', currentUserId);

  try {
    const { data } = await API.put(url);
    dispatch(
      addToast({
        type: 'success',
        message: data.message,
      })
    );
    return dispatch({ type: TEST_EMAIL_RESPONSE });
  } catch (error) {
    dispatch(
      addToast({
        type: 'error',
        message:
          (error.response &&
            error.response.data &&
            error.response.data.message) ||
          error.message,
      })
    );
    return dispatch({ type: TEST_EMAIL_RESPONSE });
  }
};
