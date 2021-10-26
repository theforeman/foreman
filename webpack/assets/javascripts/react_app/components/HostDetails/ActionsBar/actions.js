import { visit } from '../../../../foreman_navigation';
import { foremanUrl } from '../../../common/helpers';
import { sprintf, translate as __ } from '../../../common/I18n';
import { openConfirmModal } from '../../ConfirmModal';
import { APIActions } from '../../../redux/API';
import { HOST_DETAILS_KEY } from '../consts';
import { defaultErrorToast } from '../../../redux/API/APIHelpers';

export const deleteHost = (
  hostName,
  compute,
  destroyVmOnHostDelete
) => dispatch => {
  const successToast = () =>
    sprintf(__('Host %s has been removed successfully'), hostName);
  const url = foremanUrl(`/api/hosts/${hostName}`);
  // TODO: Replace with a checkbox instead of a global setting for cascade host destroy
  const warningMessage = () => {
    if (compute) {
      return destroyVmOnHostDelete
        ? sprintf(
            __(
              'Are you sure you want to delete host %s? This will delete the VM and its disks, and is irreversible. This behavior can be changed via global setting "Destroy associated VM on host delete".'
            ),
            hostName
          )
        : sprintf(
            __(
              'Are you sure you want to delete host %s? It is irreversible, but VM and its disks will not be deleted. This behavior can be changed via global setting "Destroy associated VM on host delete".'
            ),
            hostName
          );
    }
    return sprintf(
      __(
        'Are you sure you want to delete host %s ? This action is irreversible'
      ),
      hostName
    );
  };

  dispatch(
    openConfirmModal({
      isWarning: true,
      title: __('Delete host?'),
      confirmButtonText: __('Delete host'),
      onConfirm: () =>
        dispatch(
          APIActions.delete({
            url,
            key: `${hostName}-DELETE`,
            successToast,
            errorToast: defaultErrorToast,
            handleSuccess: () => visit(foremanUrl('/hosts')),
          })
        ),
      message: warningMessage(),
    })
  );
};

export const updateHost = hostId => dispatch => {
  const url = foremanUrl(`/api/hosts/${hostId}`);
  dispatch(
    APIActions.get({
      url,
      key: HOST_DETAILS_KEY,
    })
  );
};

export const buildHost = hostId => dispatch => {
  const successToast = () =>
    sprintf(__('Host %s will be built next boot'), hostId);

  const url = foremanUrl(`/hosts/${hostId}/setBuild`);
  dispatch(
    APIActions.put({
      url,
      key: `${hostId}_BUILD`,
      successToast,
      errorToast: defaultErrorToast,
      handleSuccess: () => dispatch(updateHost(hostId)),
    })
  );
};

export const cancelBuild = hostId => dispatch => {
  const successToast = () =>
    sprintf(__('Canceled pending build for %s'), hostId);
  const url = foremanUrl(`/hosts/${hostId}/cancelBuild`);
  dispatch(
    APIActions.get({
      url,
      key: `${hostId}_CANCEL_BUILD`,
      successToast,
      errorToast: defaultErrorToast,
      handleSuccess: () => dispatch(updateHost(hostId)),
    })
  );
};
