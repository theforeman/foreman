import { APIActions } from '../../../redux/API';
import { HOST_STATUSES_KEY } from './Constants';
import { foremanUrl } from '../../../common/helpers';

export const forgetStatus = (hostName, { label, id }) => dispatch => {
  const successToast = () => `Status ${label} has been removed`;
  const errorToast = ({ message }) => message;
  const url = foremanUrl(`/hosts/${hostName}/forget_status?status=${id}`);
  dispatch(
    APIActions.post({
      url: foremanUrl(url),
      key: HOST_STATUSES_KEY,
      successToast,
      errorToast,
      updateData: prevState => ({
        ...prevState,
        statuses: prevState.statuses.filter(status => status.id !== id),
      }),
    })
  );
};
