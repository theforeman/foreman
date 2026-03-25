import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import {
  Modal,
  ModalVariant,
  Button,
  TextContent,
  Text,
  FormGroup,
  ToggleGroup,
  ToggleGroupItem,
} from '@patternfly/react-core';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from '../../../../common/I18n';
import { bulkManageNotifications } from './actions';
import { BULK_MANAGE_NOTIFICATIONS_KEY } from './constants';
import { failedHostsToastParams } from '../helpers';
import { addToast } from '../../../ToastsList/slice';

const BulkManageNotificationsModal = ({
  selectedCount,
  fetchBulkParams,
  isOpen,
  closeModal,
  onSuccess: onSuccessCallback,
}) => {
  const [notificationsEnabled, setNotificationsEnabled] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const dispatch = useDispatch();

  const handleModalClose = () => {
    setNotificationsEnabled(null);
    setIsLoading(false);
    closeModal();
  };

  const handleSuccess = response => {
    dispatch(
      addToast({
        type: 'success',
        message: response.data.message,
      })
    );
    // Refresh the hosts table while preserving the current search query
    if (onSuccessCallback) onSuccessCallback();
    handleModalClose();
  };

  const handleError = error => {
    const apiError = error?.response?.data?.error;
    if (apiError) {
      dispatch(
        addToast(
          failedHostsToastParams({
            ...apiError,
            key: BULK_MANAGE_NOTIFICATIONS_KEY,
          })
        )
      );
    }
    handleModalClose();
  };

  const handleSubmit = () => {
    setIsLoading(true);
    const payload = {
      included: {
        search: fetchBulkParams(),
      },
      enabled: notificationsEnabled,
    };
    dispatch(bulkManageNotifications(payload, handleSuccess, handleError));
  };

  return (
    <Modal
      variant={ModalVariant.small}
      title={__('Manage notifications')}
      isOpen={isOpen}
      onClose={handleModalClose}
      ouiaId="bulk-manage-notifications-modal"
      aria-labelledby="manage-notifications-modal"
      actions={[
        <Button
          key="confirm"
          variant="primary"
          onClick={handleSubmit}
          isDisabled={isLoading || notificationsEnabled === null}
          isLoading={isLoading}
          spinnerAriaLabel={__('Loading')}
          ouiaId="bulk-manage-notifications-confirm"
        >
          {__('Confirm')}
        </Button>,
        <Button
          key="cancel"
          variant="link"
          onClick={handleModalClose}
          isDisabled={isLoading}
          ouiaId="bulk-manage-notifications-cancel"
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      <TextContent className="pf-v5-u-mb-md">
        <Text
          component="p"
          className="pf-v5-u-font-size-md"
          ouiaId="manage-notifications-hosts-count"
        >
          <FormattedMessage
            id="bulk-manage-notifications-description"
            defaultMessage="Enable or disable email notification alerts for {boldCount} selected {count, plural, one {host} other {hosts}}."
            values={{
              count: selectedCount,
              boldCount: <strong>{selectedCount}</strong>,
            }}
          />
        </Text>
        <Text
          component="small"
          className="pf-v5-u-color-200 pf-v5-u-font-size-sm"
          ouiaId="manage-notifications-explanation"
        >
          {__(
            'Notifications are sent when a host reports a configuration error via Puppet, Ansible, or another configuration management tool.'
          )}
        </Text>
        <Text
          component="small"
          className="pf-v5-u-color-200 pf-v5-u-font-size-sm"
          ouiaId="manage-notifications-enablement-state-notice"
        >
          {__('Enablement state of the selected hosts may vary.')}
        </Text>
      </TextContent>
      <FormGroup fieldId="manage-notifications-toggle">
        <ToggleGroup aria-label={__('Notification state')}>
          <ToggleGroupItem
            text={__('Enable')}
            buttonId="manage-notifications-enable"
            isSelected={notificationsEnabled === true}
            onChange={() =>
              setNotificationsEnabled(
                notificationsEnabled === true ? null : true
              )
            }
            isDisabled={isLoading}
          />
          <ToggleGroupItem
            text={__('Disable')}
            buttonId="manage-notifications-disable"
            isSelected={notificationsEnabled === false}
            onChange={() =>
              setNotificationsEnabled(
                notificationsEnabled === false ? null : false
              )
            }
            isDisabled={isLoading}
          />
        </ToggleGroup>
      </FormGroup>
    </Modal>
  );
};

BulkManageNotificationsModal.propTypes = {
  selectedCount: PropTypes.number,
  fetchBulkParams: PropTypes.func.isRequired,
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  onSuccess: PropTypes.func,
};

BulkManageNotificationsModal.defaultProps = {
  selectedCount: 0,
  isOpen: false,
  closeModal: () => {},
  onSuccess: undefined,
};

export default BulkManageNotificationsModal;
