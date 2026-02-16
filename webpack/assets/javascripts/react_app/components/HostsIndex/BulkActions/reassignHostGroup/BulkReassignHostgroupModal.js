import React, { useState, useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  Modal,
  Button,
  TextContent,
  Text,
  SelectOption,
} from '@patternfly/react-core';
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
import SkeletonLoader from '../../../common/SkeletonLoader';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from '../../../../routes/Hosts/constants';
import './BulkReassignHostgroupModal.scss';

// Helper function to format hostgroup title for display
const formatHostgroupTitle = title => {
  if (!title) return '';
  // Replace / with > for better hierarchy visualization
  return title.replace(/\//g, ' > ');
};

// Component to render styled hostgroup label in dropdown options
const HostgroupOptionLabel = ({ formattedTitle }) => {
  if (!formattedTitle) return null;

  const parts = formattedTitle.split(' > ');
  if (parts.length === 1) {
    return <strong>{parts[0]}</strong>;
  }

  const parentParts = parts.slice(0, -1);
  const finalPart = parts[parts.length - 1];

  return (
    <span className="hostgroup-label">
      {parentParts.map((part, index) => (
        <span key={`${part}-${index}`} className="hostgroup-name-parent">
          {part}
        </span>
      ))}
      <strong>{finalPart}</strong>
    </span>
  );
};

HostgroupOptionLabel.propTypes = {
  formattedTitle: PropTypes.string,
};

HostgroupOptionLabel.defaultProps = {
  formattedTitle: '',
};

const BulkReassignHostgroupModal = ({
  isOpen,
  closeModal,
  selectedCount,
  fetchBulkParams,
}) => {
  const dispatch = useDispatch();
  const [hostgroupId, setHostgroupId] = useState('');
  const [selectedName, setSelectedName] = useState('');
  const [inputValue, setInputValue] = useState('');
  const [filterValue, setFilterValue] = useState('');

  const hostgroups = useSelector(state =>
    selectAPIResponse(state, HOSTGROUP_KEY)
  );
  const hostgroupStatus =
    useSelector(state => selectAPIStatus(state, HOSTGROUP_KEY)) ||
    STATUS.PENDING;
  const hostUpdateStatus = useSelector(state =>
    selectAPIStatus(state, BULK_REASSIGN_HOSTGROUP_KEY)
  );

  const handleModalClose = () => {
    setHostgroupId('');
    setSelectedName('');
    setInputValue('');
    setFilterValue('');
    closeModal();
  };

  const [hgSelectOpen, setHgSelectOpen] = useState(false);

  // Extract results for useMemo dependency
  const hostgroupResults = hostgroups?.results;

  // Filter hostgroups based on search input
  const filteredHostgroups = useMemo(() => {
    if (!hostgroupResults) return [];
    if (!filterValue) return hostgroupResults;

    return hostgroupResults.filter(
      hg =>
        hg.title.toLowerCase().includes(filterValue.toLowerCase()) ||
        hg.name.toLowerCase().includes(filterValue.toLowerCase())
    );
  }, [filterValue, hostgroupResults]);

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

  const handleClear = () => {
    setHostgroupId('');
    setSelectedName('');
    setInputValue('');
    setFilterValue('');
  };

  const handleInputValueChange = value => {
    setInputValue(value);
    setFilterValue(value);
    if (value !== selectedName) {
      setSelectedName('');
      setHostgroupId('');
    }
    // Auto-open dropdown when user starts typing
    if (value && !hgSelectOpen) {
      setHgSelectOpen(true);
    }
  };

  const handleSelect = (event, value) => {
    const selectedHg = filteredHostgroups.find(hg => hg.name === value);
    if (selectedHg) {
      setHostgroupId(selectedHg.id);
      setSelectedName(selectedHg.name);
      setInputValue(selectedHg.name);
      setFilterValue('');
    }
    setHgSelectOpen(false);
  };

  const modalActions = [
    <Button
      key="add"
      ouiaId="bulk-reassign-hg-modal-add-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={
        hostUpdateStatus === STATUS.PENDING ||
        hostgroupStatus !== STATUS.RESOLVED
      }
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
      <SkeletonLoader status={hostgroupStatus} skeletonProps={{ count: 3 }}>
        <HostGroupSelect
          onClear={handleClear}
          headerText={__('Select host group')}
          selected={selectedName}
          isOpen={hgSelectOpen}
          onToggle={setHgSelectOpen}
          inputValue={inputValue}
          onInputValueChange={handleInputValueChange}
          onSelect={handleSelect}
          placeholder={__('Select host group')}
        >
          {filteredHostgroups.map(hg => {
            const formattedTitle = formatHostgroupTitle(hg.title);
            return (
              <SelectOption key={hg.id} value={hg.name}>
                <HostgroupOptionLabel formattedTitle={formattedTitle} />
              </SelectOption>
            );
          })}
        </HostGroupSelect>
      </SkeletonLoader>
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
