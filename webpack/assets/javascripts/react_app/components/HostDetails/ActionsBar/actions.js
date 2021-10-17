import { visit } from '../../../../foreman_navigation';
import { foremanUrl } from '../../../common/helpers';
import { sprintf, translate as __ } from '../../../common/I18n';
import { APIActions } from '../../../redux/API';

export const deleteHost = (
  hostName,
  compute,
  destroyVmOnHostDelete
) => dispatch => {
  const successToast = () =>
    sprintf(__('Host %s has been removed successfully'), hostName);
  const errorToast = ({ message }) => message;
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

  if (window.confirm(warningMessage())) {
    dispatch(
      APIActions.delete({
        url,
        key: `${hostName}-DELETE`,
        successToast,
        errorToast,
        handleSuccess: () => visit(foremanUrl('/hosts')),
      })
    );
  }
};
