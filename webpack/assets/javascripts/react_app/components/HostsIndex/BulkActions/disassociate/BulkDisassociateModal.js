import React from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import {
  Modal,
  Alert,
  Button,
  TextContent,
  Text,
  TreeView,
} from '@patternfly/react-core';
import { addToast } from '../../../ToastsList/slice';
import { foremanUrl } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import { BULK_DISASSOCIATE_KEY, bulkDisassociate } from './actions';
import { APIActions } from '../../../../redux/API';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from '../../../../routes/Hosts/constants';
import { buildBulkRequestBody, failedHostsToastParams } from '../helpers';

const BulkDisassociateModal = ({
  isOpen,
  closeModal,
  selectAllHostsMode,
  selectedCount,
  selectedResults,
  fetchBulkParams,
  organizationId,
  locationId,
}) => {
  const dispatch = useDispatch();
  const hostsWithComputeResource = selectedResults?.filter(
    h => h.compute_resource_id && h.uuid
  );
  const hostsWithoutComputeResource = selectedResults?.filter(
    h => !hostsWithComputeResource.includes(h)
  );
  const selectedResultsEmpty = selectedResults?.length === 0;

  const selectedTreeViewData = [
    {
      name: __('Selected hosts'),
      id: 'selected-hosts-tree-view-title',
      customBadgeContent: selectAllHostsMode ? 'All' : selectedCount,
    },
  ];
  const applicableTreeViewData = [
    {
      name: __('Hosts associated to compute resources'),
      id: 'applicable-hosts-tree-view-title',
      customBadgeContent: hostsWithComputeResource?.length,
    },
  ];
  const excludedTreeViewData = [
    {
      name: __('Excluded hosts'),
      id: 'excluded-hosts-tree-view-title',
      customBadgeContent: hostsWithoutComputeResource?.length,
    },
  ];

  const handleError = response => {
    closeModal();
    dispatch(
      addToast(
        failedHostsToastParams({
          ...response.data.error,
          key: BULK_DISASSOCIATE_KEY,
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
    closeModal();
  };

  const handleConfirm = () => {
    const queryString = selectedResultsEmpty
      ? fetchBulkParams()
      : `id ^ (${hostsWithComputeResource.map(h => h.id).join(',')})`;
    const requestBody = buildBulkRequestBody({
      fetchBulkParams,
      organizationId,
      locationId,
      includedSearch: queryString,
    });

    dispatch(bulkDisassociate(requestBody, handleSuccess, handleError));
  };

  const modalActions = [
    <Button
      key="add"
      ouiaId="bulk-disassociate-modal-add-button"
      variant="primary"
      onClick={handleConfirm}
      isDisabled={
        hostsWithComputeResource?.length === 0 && !selectedResultsEmpty
      }
    >
      {__('Disassociate')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-disassociate-modal-cancel-button"
      variant="link"
      onClick={closeModal}
    >
      {__('Cancel')}
    </Button>,
  ];

  return (
    <Modal
      isOpen={isOpen}
      onClose={closeModal}
      onEscapePress={closeModal}
      title={__('Disassociate hosts')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-disassociate-modal"
      key="bulk-disassociate-modal"
      ouiaId="bulk-disassociate-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-disassociate-options">
          {__(
            'This will disassociate the host in Foreman from its compute resource.'
          )}
          <br />
          {__(
            'After disassociating, a host can be deleted from Foreman without affecting its virtual machine.'
          )}
        </Text>
      </TextContent>
      <Alert
        style={{ marginTop: '2rem', marginBottom: '1rem' }}
        variant="warning"
        isInline
        isPlain
        title={__('Hosts without a compute resource will be excluded.')}
        ouiaId="warning-alert"
      />
      <div style={{ width: '70%', maxHeight: '50%', marginLeft: '-1rem' }}>
        {selectedResultsEmpty && (
          <TreeView
            data={selectedTreeViewData}
            aria-label={__('Selected hosts')}
            hasBadges
          />
        )}
        {!selectedResultsEmpty && (
          <>
            <TreeView
              data={applicableTreeViewData}
              aria-label={__('Hosts associated to compute resources')}
              hasBadges
            />
            <TreeView
              data={excludedTreeViewData}
              aria-label={__('Excluded hosts')}
              hasBadges
            />
          </>
        )}
      </div>
    </Modal>
  );
};

BulkDisassociateModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedResults: PropTypes.array,
  fetchBulkParams: PropTypes.func.isRequired,
  selectedCount: PropTypes.number.isRequired,
  selectAllHostsMode: PropTypes.bool.isRequired,
  organizationId: PropTypes.number,
  locationId: PropTypes.number,
};

BulkDisassociateModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  selectedResults: [],
  organizationId: undefined,
  locationId: undefined,
};

export default BulkDisassociateModal;
