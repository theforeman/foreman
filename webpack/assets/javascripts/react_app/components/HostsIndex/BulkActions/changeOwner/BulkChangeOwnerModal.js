import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { useDispatch, useSelector } from 'react-redux';
import {
  Modal,
  Button,
  TextContent,
  Text,
  Select,
  SelectOption,
  SelectList,
  SelectGroup,
  MenuToggle,
} from '@patternfly/react-core';
import { addToast } from '../../../ToastsList/slice';
import { translate as __ } from '../../../../common/I18n';
import {
  BULK_CHANGE_OWNER_KEY,
  bulkChangeOwner,
  fetchUsers,
  fetchUsergroups,
  USER_KEY,
  USERGROUP_KEY,
} from './actions';
import { foremanUrl } from '../../../../common/helpers';
import { APIActions } from '../../../../redux/API';
import { STATUS } from '../../../../constants';
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../../../redux/API/APISelectors';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from '../../../../routes/Hosts/constants';
import { failedHostsToastParams } from '../helpers';

const BulkChangeOwnerModal = ({
  isOpen,
  closeModal,
  selectAllHostsMode,
  selectedCount,
  fetchBulkParams,
}) => {
  const dispatch = useDispatch();
  const [ownerId, setOwnerId] = useState('');
  const [ownerSelectOpen, setOwnerSelectOpen] = useState(false);

  useEffect(() => {
    dispatch(fetchUsers());
    dispatch(fetchUsergroups());
  }, [dispatch]);

  const users = useSelector(state => selectAPIResponse(state, USER_KEY));
  const usergroups = useSelector(state =>
    selectAPIResponse(state, USERGROUP_KEY)
  );
  const userStatus = useSelector(state => selectAPIStatus(state, USER_KEY));
  const usergroupStatus = useSelector(state =>
    selectAPIStatus(state, USERGROUP_KEY)
  );

  const onToggleClick = () => {
    setOwnerSelectOpen(!ownerSelectOpen);
  };

  const handleOwnerSelect = (event, selection) => {
    setOwnerId(selection);
    setOwnerSelectOpen(false);
  };

  const getOwnerLabel = id => {
    if (id.endsWith('-Users')) {
      const userId = id.replace('-Users', '');
      return users?.results?.find(u => u.id.toString() === userId)?.login || id;
      // eslint-disable-next-line spellcheck/spell-checker
    } else if (id.endsWith('-Usergroups')) {
      // eslint-disable-next-line spellcheck/spell-checker
      const groupId = id.replace('-Usergroups', '');
      return (
        usergroups?.results?.find(ug => ug.id.toString() === groupId)?.name ||
        id
      );
    }
    return id;
  };

  const toggle = toggleRef => (
    <MenuToggle
      ref={toggleRef}
      onClick={onToggleClick}
      isExpanded={ownerSelectOpen}
      style={{ width: '500px' }}
    >
      {ownerId ? getOwnerLabel(ownerId) : __('Select an owner')}
    </MenuToggle>
  );

  const handleModalClose = () => {
    setOwnerId('');
    closeModal();
  };

  const handleError = response => {
    handleModalClose();
    dispatch(
      addToast(
        failedHostsToastParams({
          ...response.data.error,
          key: BULK_CHANGE_OWNER_KEY,
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

  const handleConfirm = () => {
    const requestBody = {
      included: {
        search: fetchBulkParams(),
      },
      owner_id: ownerId,
    };

    dispatch(bulkChangeOwner(requestBody, handleSuccess, handleError));
  };

  const modalActions = [
    <Button
      key="add"
      ouiaId="bulk-change-owner-modal-add-button"
      variant="primary"
      onClick={handleConfirm}
      isDisabled={ownerId === ''}
      isLoading={
        userStatus === STATUS.PENDING || usergroupStatus === STATUS.PENDING
      }
    >
      {__('Change owner')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-change-owner-modal-cancel-button"
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
      title={__('Change Owner')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-change-owner-modal"
      key="bulk-change-owner-modal"
      ouiaId="bulk-change-owner-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-change-owner-options">
          {selectAllHostsMode ? (
            <FormattedMessage
              id="bulk-change-owner-warning-message-all"
              defaultMessage="Changing the owner will affect {boldCount} selected hosts. Some hosts may already have been associated with the selected owner."
              values={{
                boldCount: <strong>{__('All')}</strong>,
              }}
            />
          ) : (
            <FormattedMessage
              id="bulk-change-owner-warning-message"
              defaultMessage="Changing the owner will affect {boldCount} selected {count, plural, one {host} other {hosts}}. Some hosts may already have been associated with the selected owner."
              values={{
                count: selectedCount,
                boldCount: <strong>{selectedCount}</strong>,
              }}
            />
          )}
        </Text>
      </TextContent>
      {userStatus === STATUS.RESOLVED && usergroupStatus === STATUS.RESOLVED && (
        <Select
          id="single-grouped-select"
          isOpen={ownerSelectOpen}
          selected={ownerId}
          onSelect={handleOwnerSelect}
          onOpenChange={isSelectOpen => setOwnerSelectOpen(isSelectOpen)}
          toggle={toggle}
          shouldFocusToggleOnSelect
          ouiaId="bulk-change-owner-select"
        >
          {users && (
            <SelectGroup label="Users">
              <SelectList>
                {users.results?.map(u => (
                  <SelectOption key={`${u.id}-Users`} value={`${u.id}-Users`}>
                    {u.login}
                  </SelectOption>
                ))}
              </SelectList>
            </SelectGroup>
          )}
          {usergroups && (
            // eslint-disable-next-line spellcheck/spell-checker
            <SelectGroup label="Usergroups">
              <SelectList>
                {usergroups?.results?.map(ug => (
                  <SelectOption
                    // eslint-disable-next-line spellcheck/spell-checker
                    key={`${ug.id}-Usergroups`}
                    // eslint-disable-next-line spellcheck/spell-checker
                    value={`${ug.id}-Usergroups`}
                  >
                    {ug.name}
                  </SelectOption>
                ))}
              </SelectList>
            </SelectGroup>
          )}
        </Select>
      )}
    </Modal>
  );
};

BulkChangeOwnerModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  fetchBulkParams: PropTypes.func.isRequired,
  selectedCount: PropTypes.number.isRequired,
  selectAllHostsMode: PropTypes.bool.isRequired,
};

BulkChangeOwnerModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
};

export default BulkChangeOwnerModal;
