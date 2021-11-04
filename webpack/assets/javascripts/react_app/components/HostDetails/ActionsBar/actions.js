import React from 'react';
import { FormattedMessage } from 'react-intl';
import { visit } from '../../../../foreman_navigation';
import { foremanUrl } from '../../../common/helpers';
import { sprintf, translate as __ } from '../../../common/I18n';
import { openConfirmModal } from '../../ConfirmModal';
import { APIActions } from '../../../redux/API';
import { HOST_DETAILS_KEY } from '../consts';
import { selectAPIResponse } from '../../../redux/API/APISelectors';
import { POWER_REQURST_KEY } from '../DetailsCard/PowerStatus/constants';

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
  const cascadeMessage = () => {
    if (compute) {
      return destroyVmOnHostDelete
        ? __(
            'This will delete the VM and its disks. This behavior can be changed via global setting "Destroy associated VM on host delete".'
          )
        : __(
            'VM and its disks will not be deleted. This behavior can be changed via global setting "Destroy associated VM on host delete".'
          );
    }
    return null;
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
            errorToast,
            handleSuccess: () => visit(foremanUrl('/hosts')),
          })
        ),
      message: (
        <FormattedMessage
          id="delete-host"
          values={{
            host: <b>{hostName}</b>,
            cascade: cascadeMessage(),
          }}
          defaultMessage={__(
            'Are you sure you want to delete host {host}? This action is irreversible. {cascade}'
          )}
        />
      ),
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
  const errorToast = ({ message }) => message;
  const url = foremanUrl(`/hosts/${hostId}/setBuild`);
  dispatch(
    APIActions.put({
      url,
      key: `${hostId}_BUILD`,
      successToast,
      errorToast,
      handleSuccess: () => dispatch(updateHost(hostId)),
    })
  );
};

export const cancelBuild = hostId => dispatch => {
  const successToast = () =>
    sprintf(__('Canceled pending build for %s'), hostId);
  const errorToast = ({ message }) => message;
  const url = foremanUrl(`/hosts/${hostId}/cancelBuild`);
  dispatch(
    APIActions.get({
      url,
      key: `${hostId}_CANCEL_BUILD`,
      successToast,
      errorToast,
      handleSuccess: () => dispatch(updateHost(hostId)),
    })
  );
};

export const isHostTurnOn = store => {
  const { state } = selectAPIResponse(store, POWER_REQURST_KEY);
  return state === 'on';
};
