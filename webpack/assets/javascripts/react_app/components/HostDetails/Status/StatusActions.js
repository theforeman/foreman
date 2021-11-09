import { APIActions } from '../../../redux/API';
import { HOST_STATUSES_KEY, CLEAR_STATUS_KEY } from './Constants';
import { foremanUrl } from '../../../common/helpers';

const getStatuses = hostName => dispatch => {
  const url = foremanUrl(`/hosts/${hostName}/statuses`);
  dispatch(
    APIActions.get({
      url,
      key: HOST_STATUSES_KEY,
    })
  );
};

export const forgetStatus = (hostName, { label, id }) => dispatch => {
  const successToast = () => `Status ${label} has been removed`;
  const errorToast = ({ message }) => message;
  const url = foremanUrl(`/hosts/${hostName}/forget_status?status=${id}`);
  dispatch(
    APIActions.post({
      url: foremanUrl(url),
      key: CLEAR_STATUS_KEY,
      successToast,
      errorToast,
      handleSuccess: () => dispatch(getStatuses(hostName)),
    })
  );
};
