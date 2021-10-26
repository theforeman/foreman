import { APIActions } from '../../../redux/API';
import { HOST_STATUSES_KEY } from './Constants';
import { foremanUrl } from '../../../common/helpers';
import { defaultErrorToast } from '../../../redux/API/APIHelpers';

export const forgetStatus = (hostName, { label, id }) => dispatch => {
  const successToast = () => `Status ${label} has been removed`;
  const url = foremanUrl(`/hosts/${hostName}/forget_status?status=${id}`);
  dispatch(
    APIActions.post({
      url: foremanUrl(url),
      key: HOST_STATUSES_KEY,
      successToast,
      errorToast: defaultErrorToast,
      updateData: prevState => ({
        ...prevState,
        statuses: prevState.statuses.filter(status => status.id !== id),
      }),
    })
  );
};
