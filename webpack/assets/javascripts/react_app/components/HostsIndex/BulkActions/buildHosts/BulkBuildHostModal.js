import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  Modal,
  Button,
  TextContent,
  Text,
  Checkbox,
  Radio,
} from '@patternfly/react-core';
import { addToast } from '../../../ToastsList/slice';
import { translate as __ } from '../../../../common/I18n';
import { failedHostsToastParams } from '../helpers';
import { STATUS } from '../../../../constants';
import { selectAPIStatus } from '../../../../redux/API/APISelectors';
import { bulkBuildHosts, HOST_BUILD_KEY } from './actions';

const BulkBuildHostModal = ({
  isOpen,
  closeModal,
  selectedCount,
  fetchBulkParams,
}) => {
  const dispatch = useDispatch();
  const [buildRadioChecked, setBuildRadioChecked] = useState(true);
  const [rebootChecked, setRebootChecked] = useState(false);
  const hostUpdateStatus = useSelector(state =>
    selectAPIStatus(state, HOST_BUILD_KEY)
  );
  const handleModalClose = () => {
    setRebootChecked(false);
    setBuildRadioChecked(true);
    closeModal();
  };

  const handleError = ({ response }) => {
    handleModalClose();
    dispatch(
      addToast(
        failedHostsToastParams({ ...response.data.error, key: HOST_BUILD_KEY })
      )
    );
  };
  const handleSave = () => {
    const requestBody = {
      included: {
        search: fetchBulkParams(),
      },
      reboot: rebootChecked,
      rebuild_configuration: !buildRadioChecked,
    };

    dispatch(bulkBuildHosts(requestBody, handleModalClose, handleError));
  };

  const handleBuildRadioSelected = selected => {
    setBuildRadioChecked(selected);
    if (!selected) {
      setRebootChecked(false);
    }
  };
  const modalActions = [
    <Button
      key="add"
      ouiaId="bulk-build-hosts-modal-add-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={hostUpdateStatus === STATUS.PENDING}
      isLoading={hostUpdateStatus === STATUS.PENDING}
    >
      {__('Confirm')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-build-hosts-modal-cancel-button"
      variant="link"
      onClick={handleModalClose}
    >
      Cancel
    </Button>,
  ];
  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={__('Build management')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-build-hosts-modal"
      key="bulk-build-hosts-modal"
      ouiaId="bulk-build-hosts-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-set-build-options">
          <FormattedMessage
            defaultMessage={__(
              'Choose an action that will be performed on {hosts}.'
            )}
            values={{
              hosts: (
                <strong>
                  <FormattedMessage
                    defaultMessage="{count, plural, one {# {singular}} other {# {plural}}}"
                    values={{
                      count: selectedCount,
                      singular: __('selected host'),
                      plural: __('selected hosts'),
                    }}
                    id="bulk-build-hosts-selected-hosts"
                  />
                </strong>
              ),
            }}
            id="bulk-build-host-description"
          />
        </Text>
      </TextContent>
      <hr />
      <Radio
        isChecked={buildRadioChecked}
        name="buildHostRadioGroup"
        onChange={(_event, checked) => handleBuildRadioSelected(checked)}
        label={__('Build')}
        id="build-host-radio"
        ouiaId="build-host-radio"
        body={
          <Checkbox
            label={__('Reboot now')}
            id="reboot-now-checkbox-id"
            name="reboot-now"
            isChecked={rebootChecked}
            isDisabled={!buildRadioChecked}
            onChange={(_event, val) => setRebootChecked(val)}
            ouiaId="build-reboot-checkbox"
          />
        }
      />
      <hr />
      <Radio
        name="buildHostRadioGroup"
        onChange={(_event, checked) => handleBuildRadioSelected(!checked)}
        label={__('Rebuild provisioning configuration only')}
        id="rebuild-host-radio"
        ouiaId="rebuild-host-radio"
      />
    </Modal>
  );
};

BulkBuildHostModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedCount: PropTypes.number.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
};

BulkBuildHostModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
};

export default BulkBuildHostModal;
