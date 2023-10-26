import React from 'react';
import { FormattedMessage } from 'react-intl';
import { visit } from '../../../../foreman_navigation';
import { foremanUrl } from '../../../common/helpers';
import { sprintf, translate as __ } from '../../../common/I18n';
import { openConfirmModal } from '../../ConfirmModal';
import { APIActions } from '../../../redux/API';
import './bulkDeleteModal.scss';

export const bulkDeleteHosts = ({
  bulkParams,
  selectedCount,
  destroyVmOnHostDelete,
}) => dispatch => {
  const successToast = () => sprintf(__('%s hosts deleted'), selectedCount);
  const errorToast = ({ message }) => message;
  const url = foremanUrl(`/api/v2/hosts/bulk?search=${bulkParams}`);

  // TODO: Replace with a checkbox instead of a global setting for cascade host destroy
  const cascadeMessage = () =>
    destroyVmOnHostDelete
      ? __(
          'For hosts with compute resources, this will delete the VM and its disks.'
        )
      : __(
          'For hosts with compute resources, VMs and their disks will not be deleted.'
        );

  dispatch(
    openConfirmModal({
      isWarning: true,
      isDireWarning: true,
      id: 'bulk-delete-hosts-modal',
      title: (
        <FormattedMessage
          defaultMessage="Delete {count, plural, one {{singular}} other {{plural}}}?"
          values={{
            count: selectedCount,
            singular: __('host'),
            plural: __('hosts'),
          }}
          id="bulk-delete-host-count"
        />
      ),
      confirmButtonText: __('Delete'),
      onConfirm: () =>
        dispatch(
          APIActions.delete({
            url,
            key: `BULK-HOSTS-DELETE`,
            successToast,
            errorToast,
            handleSuccess: () => visit(foremanUrl('/new/hosts')),
          })
        ),
      message: (
        <FormattedMessage
          id="bulk-delete-hosts"
          values={{
            hostsCount: (
              <strong>
                <FormattedMessage
                  defaultMessage="{count, plural, one {# {singular}} other {# {plural}}}"
                  values={{
                    count: selectedCount,
                    singular: __('host'),
                    plural: __('hosts'),
                  }}
                  id="bulk-delete-host-count"
                />
              </strong>
            ),
            cascade: cascadeMessage(),
            settings: (
              <a href={foremanUrl('/settings?search=destroy')}>
                {__('Provisioning settings')}
              </a>
            ),
            br: <br />,
          }}
          defaultMessage={__(
            '{hostsCount} will be deleted. This action is irreversible. {br}{br} {cascade} {br}{br} This behavior can be changed via global setting "Destroy associated VM on host delete" in {settings}.{br}{br}'
          )}
        />
      ),
    })
  );
};
