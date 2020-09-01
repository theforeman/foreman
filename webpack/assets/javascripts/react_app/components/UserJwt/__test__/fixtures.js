import { noop } from '../../../common/helpers';
import { STATUS } from '../../../constants';

export const formProps = {
  handleSubmit: noop,
};

const token = 'token23';

export const fieldOk = {
  apiStatus: STATUS.RESOLVED,
  token,
};

export const fieldError = {
  apiStatus: STATUS.ERROR,
  token,
};

export const fieldPending = {
  apiStatus: STATUS.PENDING,
  token,
};
