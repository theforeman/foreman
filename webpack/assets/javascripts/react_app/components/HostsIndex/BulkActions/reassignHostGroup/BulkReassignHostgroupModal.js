import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { Modal, Button, TextContent, Text } from '@patternfly/react-core';
import { SelectOption } from '@patternfly/react-core/deprecated';
import { addToast } from '../../../ToastsList/slice';
import { translate as __ } from '../../../../common/I18n';
import { failedHostsToastParams } from '../helpers';
import { STATUS } from '../../../../constants';
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../../../redux/API/APISelectors';
import {
  BULK_REASSIGN_HOSTGROUP_KEY,
  bulkReassignHostgroups,
  fetchHostgroups,
  HOSTGROUP_KEY,
} from './actions';
import { foremanUrl } from '../../../../common/helpers';
import { APIActions } from '../../../../redux/API';
import HostGroupSelect from './HostGroupSelect';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from '../../../../routes/Hosts/constants';

const BulkReassignHostgroupModal = ({
  isOpen,
  closeModal,
  selectedCount,
  fetchBulkParams,
}) => {
  const dispatch = useDispatch();
  const [hostgroupId, setHostgroupId] = useState('');
  const hostgroups = useSelector(state =>
    selectAPIResponse(state, HOSTGROUP_KEY)
  );
  const hostgroupStatus = useSelector(state =>
    selectAPIStatus(state, HOSTGROUP_KEY)
  );
  const hostUpdateStatus = useSelector(state =>
    selectAPIStatus(state, BULK_REASSIGN_HOSTGROUP_KEY)
  );
  const handleModalClose = () => {
    setHostgroupId('');
    closeModal();
  };

  const [hgSelectOpen, setHgSelectOpen] = useState(false);

  useEffect(() => {
    dispatch(fetchHostgroups());
  }, [dispatch]);

  const handleError = response => {
    handleModalClose();
    dispatch(
      addToast(
        failedHostsToastParams({
          ...response.data.error,
          key: BULK_REASSIGN_HOSTGROUP_KEY,
        })
      )
    );
  };

  const handleSuccess = response => {
    dispatch(
      addToast({
        type: 'success',
        message: response.data.message,
      })
    );
    dispatch(
      APIActions.get({
        key: API_REQUEST_KEY,
        url: foremanUrl(HOSTS_API_PATH),
      })
    );
    handleModalClose();
  };
  const handleSave = () => {
    const requestBody = {
      included: {
        search: fetchBulkParams(),
      },
      hostgroup_id: hostgroupId,
    };

    dispatch(bulkReassignHostgroups(requestBody, handleSuccess, handleError));
  };

  const handleHgSelect = (event, selection) => {
    setHostgroupId(selection);
    setHgSelectOpen(false);
  };

  const modalActions = [
    <Button
      key="add"
      ouiaId="bulk-reassign-hg-modal-add-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={hostUpdateStatus === STATUS.PENDING}
      isLoading={hostUpdateStatus === STATUS.PENDING}
    >
      {__('Save')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-reassign-hg-modal-cancel-button"
      variant="link"
      onClick={handleModalClose}
    >
      {__('Cancel')}
    </Button>,
  ];
  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={__('Change host group')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-reassign-hg-modal"
      key="bulk-reassign-hg-modal"
      ouiaId="bulk-reassign-hg-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-reassign-hg-options">
          <FormattedMessage
            defaultMessage={__(
              'Change the host group of {hosts}. Some hosts may already be in your chosen host group.'
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
                    id="bulk-hg-selected-host-options"
                  />
                </strong>
              ),
            }}
            id="bulk-reassign-hg-description"
          />
        </Text>
      </TextContent>
      {hostgroups && hostgroupStatus === STATUS.RESOLVED && (
        <HostGroupSelect
          onClear={() => setHostgroupId('')}
          headerText={__('Select host group')}
          selections={hostgroupId}
          onChange={value => setHostgroupId(value)}
          isOpen={hgSelectOpen}
          onToggle={isExpanded => setHgSelectOpen(isExpanded)}
          onSelect={handleHgSelect}
        >
          {hostgroups?.results?.map(hg => (
            <SelectOption key={hg.id} value={hg.id}>
              {hg.name}
            </SelectOption>
          ))}
        </HostGroupSelect>
      )}
      <hr />
    </Modal>
  );
};

BulkReassignHostgroupModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedCount: PropTypes.number.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
};

BulkReassignHostgroupModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
};

export default BulkReassignHostgroupModal;
