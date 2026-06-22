import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  Modal,
  Button,
  MenuToggle,
  SelectOption,
  TextContent,
  Text,
  TreeView,
} from '@patternfly/react-core';
import { addToast } from '../../../ToastsList/slice';
import { translate as __ } from '../../../../common/I18n';
import { STATUS } from '../../../../constants';
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../../../redux/API/APISelectors';
import {
  bulkAssignOrganization,
  bulkAssignLocation,
  fetchOrganizations,
  fetchLocations,
} from './actions';
import {
  BULK_ASSIGN_ORGANIZATION_KEY,
  BULK_ASSIGN_LOCATION_KEY,
  ORGANIZATION_KEY,
  LOCATION_KEY,
  MODAL_TYPES,
} from './BulkAssignTaxonomyConstants';
import { foremanUrl } from '../../../../common/helpers';
import { APIActions } from '../../../../redux/API';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from '../../../../routes/Hosts/constants';
import TaxonomySelect from './TaxonomySelect';
import { buildBulkRequestBody } from '../helpers';

export const BulkAssignOrganizationModal = props => (
  <BulkAssignTaxonomyModal modalType={MODAL_TYPES.ORGANIZATION} {...props} />
);
export const BulkAssignLocationModal = props => (
  <BulkAssignTaxonomyModal modalType={MODAL_TYPES.LOCATION} {...props} />
);

const BulkAssignTaxonomyModal = ({
  isOpen,
  closeModal,
  selectAllHostsMode,
  selectedCount,
  fetchBulkParams,
  organizationId,
  locationId,
  modalType,
}) => {
  const org = modalType === MODAL_TYPES.ORGANIZATION;
  const taxType = org ? 'organization' : 'location';
  const dispatch = useDispatch();
  const [taxId, setTaxId] = useState('');
  const [selectOpen, setSelectOpen] = useState(false);
  const [fixRadioChecked, setFixRadioChecked] = useState(true);
  const taxResults = useSelector(state =>
    org
      ? selectAPIResponse(state, ORGANIZATION_KEY)
      : selectAPIResponse(state, LOCATION_KEY)
  );
  const status = useSelector(state =>
    org
      ? selectAPIStatus(state, ORGANIZATION_KEY)
      : selectAPIStatus(state, LOCATION_KEY)
  );
  const hostUpdateStatus = useSelector(state =>
    org
      ? selectAPIStatus(state, BULK_ASSIGN_ORGANIZATION_KEY)
      : selectAPIStatus(state, BULK_ASSIGN_LOCATION_KEY)
  );
  const handleModalClose = () => {
    setTaxId('');
    setFixRadioChecked(true);
    closeModal();
  };

  useEffect(() => {
    org ? dispatch(fetchOrganizations()) : dispatch(fetchLocations());
  }, [dispatch, org]);

  const onToggleClick = () => {
    setSelectOpen(!selectOpen);
  };
  const toggle = toggleRef => (
    <MenuToggle
      ref={toggleRef}
      onClick={onToggleClick}
      isExpanded={selectOpen}
      style={{ width: '95%' }}
    >
      {getSelectedLabel(taxId, taxResults)}
    </MenuToggle>
  );

  const handleSelect = (event, selection) => {
    setTaxId(selection);
    setSelectOpen(false);
  };

  const getSelectedLabel = (id, taxonomy) =>
    taxonomy.results.find(t => t.id === id)?.name;

  const handleError = error => {
    const {
      response: {
        data: {
          error: { message },
        },
      },
    } = error;
    dispatch(addToast({ type: 'danger', message }));
    handleModalClose();
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
    const requestBody = buildBulkRequestBody({
      fetchBulkParams,
      organizationId,
      locationId,
      id: taxId,
      mismatch_setting: fixRadioChecked,
    });

    org
      ? dispatch(
          bulkAssignOrganization(requestBody, handleSuccess, handleError)
        )
      : dispatch(bulkAssignLocation(requestBody, handleSuccess, handleError));
  };

  const translatedTaxType = org ? __('organization') : __('location');
  const modalText = (
    <FormattedMessage
      id={`bulk-assign-${taxType}-text-message`}
      defaultMessage={__(
        'Select {taxonomy} to add hosts to. This change may affect all your selected hosts.'
      )}
      values={{ taxonomy: translatedTaxType }}
    />
  );

  const modalActions = [
    <Button
      key="add"
      ouiaId={`bulk-assign-${taxType}-modal-add-button`}
      variant="primary"
      onClick={handleSave}
      isDisabled={hostUpdateStatus === STATUS.PENDING || taxId === ''}
      isLoading={hostUpdateStatus === STATUS.PENDING}
    >
      {org ? __('Change organization') : __('Change location')}
    </Button>,
    <Button
      key="cancel"
      ouiaId={`bulk-assign-${taxType}-modal-cancel-button`}
      variant="link"
      onClick={handleModalClose}
    >
      {__('Cancel')}
    </Button>,
  ];

  const selectedTreeViewData = [
    {
      name: __('Selected hosts'),
      id: 'selected-hosts-tree-view-title',
      customBadgeContent: selectAllHostsMode ? 'All' : selectedCount,
    },
  ];

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={org ? __('Change organization') : __('Change location')}
      width="50%"
      position="top"
      actions={modalActions}
      id={`bulk-assign-${taxType}-modal`}
      key={`bulk-assign-${taxType}-modal`}
      ouiaId={`bulk-assign-${taxType}-modal`}
    >
      <TextContent>
        <Text ouiaId={`bulk-assign-${taxType}-text`}>{modalText}</Text>
      </TextContent>
      {taxResults && status === STATUS.RESOLVED && (
        <TaxonomySelect
          headerText={org ? __('Select organization') : __('Select location')}
          taxonomy={taxType}
          isOpen={selectOpen}
          selected={taxId}
          onSelect={handleSelect}
          onOpenChange={isSelectOpen => setSelectOpen(isSelectOpen)}
          toggle={toggle}
          radioChecked={fixRadioChecked}
          setRadioChecked={setFixRadioChecked}
        >
          {taxResults.results?.map(tax => (
            <SelectOption key={tax.id} value={tax.id}>
              {tax.name}
            </SelectOption>
          ))}
        </TaxonomySelect>
      )}
      <div style={{ width: '70%', maxHeight: '50%', marginLeft: '-1rem' }}>
        <TreeView
          data={selectedTreeViewData}
          aria-label={__('Selected hosts')}
          hasBadges
        />
      </div>
    </Modal>
  );
};

BulkAssignTaxonomyModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedCount: PropTypes.number.isRequired,
  selectAllHostsMode: PropTypes.bool.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
  organizationId: PropTypes.number,
  locationId: PropTypes.number,
  modalType: PropTypes.string.isRequired,
};

BulkAssignTaxonomyModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  organizationId: undefined,
  locationId: undefined,
};
