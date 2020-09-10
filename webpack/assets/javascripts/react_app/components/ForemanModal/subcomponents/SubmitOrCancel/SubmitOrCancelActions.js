import { deepPropsToCamelCase } from '../../../../common/helpers';

import { API } from '../../../../redux/API';

import { addToast } from '../../../../redux/actions/toasts';
import { translate as __ } from '../../../../common/I18n';
import {
  setModalStartSubmitting,
  setModalStopSubmitting,
} from '../../ForemanModalActions';

const onModalError = error => {
  const {
    response: {
      status,
      data: {
        error: { message, fullMessages },
      },
    } = {},
  } = deepPropsToCamelCase(error);

  if (message) {
    return message;
  }

  if (fullMessages) {
    return fullMessages.join(', ');
  }

  return `${status}: ${__('Failed to submit the request.')}`;
};

export const submitModal = ({
  url,
  message,
  method = 'delete',
  closeFn,
  getErrorMsg = onModalError,
  onSuccess = () => {},
  id,
}) => async dispatch => {
  try {
    dispatch(setModalStartSubmitting({ id }));
    const { data } = await API[method](url, {});
    dispatch(setModalStopSubmitting({ id }));
    onSuccess(data);
    closeFn();
    dispatch(
      addToast({
        type: 'success',
        message,
      })
    );
  } catch (error) {
    dispatch(setModalStopSubmitting({ id }));
    dispatch(
      addToast({
        type: 'error',
        message: getErrorMsg(error),
      })
    );
  }
};
