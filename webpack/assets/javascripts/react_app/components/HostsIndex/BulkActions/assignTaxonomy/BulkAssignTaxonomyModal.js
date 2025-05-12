import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Modal,
  Button,
  MenuToggle,
  SelectOption,
  TextContent,
  Text,
} from '@patternfly/react-core';
import { addToast } from '../../../ToastsList/slice';
import { translate as __ } from '../../../../common/I18n';
import { STATUS } from '../../../../constants';
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../../../redux/API/APISelectors';
import {
  BULK_ASSIGN_TAXONOMY_KEY,
  bulkAssignTaxonomy,
  fetchOrganizations,
  fetchLocations,
  ORGANIZATION_KEY,
  LOCATION_KEY,
} from './actions';
import { foremanUrl } from '../../../../common/helpers';
import { APIActions } from '../../../../redux/API';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from '../../../../routes/Hosts/constants';
import TaxonomySelect from './TaxonomySelect';

const BulkAssignTaxonomyModal = ({
  isOpen,
  closeModal,
  selectedCount,
  fetchBulkParams,
}) => {
  const dispatch = useDispatch();
  const [organizationId, setOrganizationId] = useState('');
  const [locationId, setLocationId] = useState('');
  const [orgSelectOpen, setOrgSelectOpen] = useState(false);
  const [locSelectOpen, setLocSelectOpen] = useState(false);
  const [orgFixRadioChecked, setOrgFixRadioChecked] = useState(true);
  const [locFixRadioChecked, setLocFixRadioChecked] = useState(true);
  const organizations = useSelector(state =>
    selectAPIResponse(state, ORGANIZATION_KEY)
  );
  const organizationStatus = useSelector(state =>
    selectAPIStatus(state, ORGANIZATION_KEY)
  );
  const locations = useSelector(state =>
    selectAPIResponse(state, LOCATION_KEY)
  );
  const locationStatus = useSelector(state =>
    selectAPIStatus(state, LOCATION_KEY)
  );
  const hostUpdateStatus = useSelector(state =>
    selectAPIStatus(state, BULK_ASSIGN_TAXONOMY_KEY)
  );
  const handleModalClose = () => {
    setOrganizationId('');
    setLocationId('');
    setOrgFixRadioChecked(true);
    setLocFixRadioChecked(true);
    closeModal();
  };

  useEffect(() => {
    dispatch(fetchOrganizations());
    dispatch(fetchLocations());
  }, [dispatch]);

  const onOrgToggleClick = () => {
    setOrgSelectOpen(!orgSelectOpen);
  };
  const toggleOrg = toggleRef => (
    <MenuToggle
      ref={toggleRef}
      onClick={onOrgToggleClick}
      isExpanded={orgSelectOpen}
      style={{ width: '95%' }}
    >
      {getSelectedLabel(organizationId, organizations)}
    </MenuToggle>
  );

  const handleOrgSelect = (event, selection) => {
    setOrganizationId(selection);
    setOrgSelectOpen(false);
  };

  const onLocToggleClick = () => {
    setLocSelectOpen(!locSelectOpen);
  };
  const toggleLoc = toggleRef => (
    <MenuToggle
      ref={toggleRef}
      onClick={onLocToggleClick}
      isExpanded={locSelectOpen}
      style={{ width: '95%' }}
    >
      {getSelectedLabel(locationId, locations)}
    </MenuToggle>
  );

  const handleLocSelect = (event, selection) => {
    setLocationId(selection);
    setLocSelectOpen(false);
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
    const requestBody = {
      included: {
        search: fetchBulkParams(),
      },
      target_location_id: locationId,
      target_organization_id: organizationId,
      mismatch_setting_location: locFixRadioChecked,
      mismatch_setting_organization: orgFixRadioChecked,
    };

    dispatch(bulkAssignTaxonomy(requestBody, handleSuccess, handleError));
  };

  const modalActions = [
    <Button
      key="add"
      ouiaId="bulk-assign-taxonomy-modal-add-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={
        hostUpdateStatus === STATUS.PENDING ||
        (organizationId === '' && locationId === '')
      }
      isLoading={hostUpdateStatus === STATUS.PENDING}
    >
      {__('Save')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-assign-taxonomy-modal-cancel-button"
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
      title={__('Change organization/location')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-assign-taxonomy-modal"
      key="bulk-assign-taxonomy-modal"
      ouiaId="bulk-assign-taxonomy-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-assign-taxonomy-options">
          {__(
            'Select organization/location to add hosts to. This change may affect all your selected hosts.'
          )}
        </Text>
      </TextContent>
      {organizations && organizationStatus === STATUS.RESOLVED && (
        <TaxonomySelect
          headerText={__('Select organization')}
          taxonomy="organization"
          isOpen={orgSelectOpen}
          selected={organizationId}
          onSelect={handleOrgSelect}
          onOpenChange={isSelectOpen => setOrgSelectOpen(isSelectOpen)}
          toggle={toggleOrg}
          radioChecked={orgFixRadioChecked}
          setRadioChecked={setOrgFixRadioChecked}
        >
          {organizations.results?.map(org => (
            <SelectOption key={org.id} value={org.id}>
              {org.name}
            </SelectOption>
          ))}
        </TaxonomySelect>
      )}
      <hr />
      {locations && locationStatus === STATUS.RESOLVED && (
        <TaxonomySelect
          headerText={__('Select location')}
          taxonomy="location"
          isOpen={locSelectOpen}
          selected={locationId}
          onSelect={handleLocSelect}
          onOpenChange={isSelectOpen => setLocSelectOpen(isSelectOpen)}
          toggle={toggleLoc}
          radioChecked={locFixRadioChecked}
          setRadioChecked={setLocFixRadioChecked}
        >
          {locations.results?.map(loc => (
            <SelectOption key={loc.id} value={loc.id}>
              {loc.name}
            </SelectOption>
          ))}
        </TaxonomySelect>
      )}
    </Modal>
  );
};

BulkAssignTaxonomyModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedCount: PropTypes.number.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
};

BulkAssignTaxonomyModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
};

export default BulkAssignTaxonomyModal;
