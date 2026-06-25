import React, { useState, useContext } from 'react';
import {
  Modal,
  ModalVariant,
  Button,
  TextContent,
  Text,
  Select,
  SelectOption,
  SelectList,
  MenuToggle,
  FormGroup,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { translate as __, sprintf } from '../../../../common/I18n';
import './BulkPowerStateModal.scss';

import { HostsPowerRefreshContext } from '../../HostsPowerRefreshContext';
import { POWER_STATES, BULK_POWER_STATE_KEY } from './constants';
import { bulkChangePowerState } from './actions';
import {
  buildBulkRequestBody,
  failedHostsToastParams,
  bulkErrorToastParams,
} from '../helpers';
import { addToast } from '../../../ToastsList/slice';

const BulkPowerStateModal = ({
  selectedHostsCount,
  fetchBulkParams,
  organizationId,
  locationId,
  isOpen,
  closeModal,
  onSuccess: onSuccessCallback,
}) => {
  const [isSelectOpen, setIsSelectOpen] = useState(false);
  const [selectedPowerState, setSelectedPowerState] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const { bumpRefresh } = useContext(HostsPowerRefreshContext);
  const dispatch = useDispatch();

  const handleSelect = (_event, value) => {
    setSelectedPowerState(value);
    setIsSelectOpen(false);
  };

  const cleanup = () => {
    setIsLoading(false);
    closeModal();
    bumpRefresh();
  };

  const handleSuccess = response => {
    dispatch(
      addToast({
        type: 'success',
        message: response.data.message,
      })
    );
    if (onSuccessCallback) onSuccessCallback();
    cleanup();
  };

  const handleError = error => {
    const apiError = error?.response?.data?.error;
    const isObject = apiError && typeof apiError === 'object';

    if (isObject) {
      let enhancedError = apiError;

      if (apiError.failed_hosts && apiError.failed_hosts.length > 0) {
        const providerErrors = [
          ...new Set(apiError.failed_hosts.map(h => h.error).filter(Boolean)),
        ];

        if (providerErrors.length > 0) {
          enhancedError = {
            ...apiError,
            message: `${apiError.message} ${providerErrors.join(' ')}`,
          };
        }
      }

      dispatch(
        addToast(
          failedHostsToastParams({
            ...enhancedError,
            key: BULK_POWER_STATE_KEY,
          })
        )
      );
    } else {
      dispatch(addToast(bulkErrorToastParams(error, BULK_POWER_STATE_KEY)));
    }

    cleanup();
  };

  const handleSubmit = () => {
    setIsLoading(true);
    const payload = buildBulkRequestBody({
      fetchBulkParams,
      organizationId,
      locationId,
      power: selectedPowerState,
    });
    dispatch(bulkChangePowerState(payload, handleSuccess, handleError));
  };

  return (
    <Modal
      variant={ModalVariant.small}
      title={__('Change power state')}
      isOpen={isOpen}
      onClose={closeModal}
      ouiaId="bulk-power-state-modal"
      aria-labelledby="power-state-modal"
      actions={[
        <Button
          key="submit"
          variant="primary"
          onClick={handleSubmit}
          isDisabled={!selectedPowerState || isLoading}
          isLoading={isLoading}
          spinnerAriaLabel={__('Loading')}
          ouiaId="bulk-power-state-apply"
        >
          {__('Apply')}
        </Button>,
        <Button
          key="cancel"
          variant="link"
          onClick={closeModal}
          isDisabled={isLoading}
          ouiaId="bulk-power-state-cancel"
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      {selectedHostsCount > 0 && (
        <TextContent className="pf-v5-u-mb-md">
          <Text
            component="small"
            className="pf-v5-u-color-200 pf-v5-u-font-size-sm"
            ouiaId="power-state-modal-hosts-count"
          >
            {sprintf(
              selectedHostsCount === 1
                ? __('%s host is selected for power state change')
                : __('%s hosts are selected for power state change'),
              selectedHostsCount
            )}
          </Text>
        </TextContent>
      )}
      <FormGroup
        label={__('Power state')}
        isRequired
        fieldId="power-state-select"
      >
        <Select
          id="power-state-select"
          isOpen={isSelectOpen}
          selected={selectedPowerState}
          onSelect={handleSelect}
          onOpenChange={open => setIsSelectOpen(open)}
          popperProps={{ direction: 'down' }}
          ouiaId="power-state-select"
          toggle={toggleRef => (
            <MenuToggle
              ref={toggleRef}
              onClick={() => setIsSelectOpen(!isSelectOpen)}
              isExpanded={isSelectOpen}
              style={{ width: '100%' }}
            >
              {selectedPowerState
                ? __(
                    POWER_STATES.find(ps => ps.value === selectedPowerState)
                      ?.label
                  )
                : __('Select power state')}
            </MenuToggle>
          )}
        >
          <SelectList className="bulk-power-state-select-list">
            <SelectOption key="placeholder" value="">
              {__('None')}
            </SelectOption>
            {POWER_STATES.map(state => (
              <SelectOption key={state.value} value={state.value}>
                {__(state.label)}
              </SelectOption>
            ))}
          </SelectList>
        </Select>
      </FormGroup>
    </Modal>
  );
};

BulkPowerStateModal.propTypes = {
  selectedHostsCount: PropTypes.number,
  fetchBulkParams: PropTypes.func.isRequired,
  organizationId: PropTypes.number,
  locationId: PropTypes.number,
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  onSuccess: PropTypes.func,
};

BulkPowerStateModal.defaultProps = {
  selectedHostsCount: 0,
  organizationId: undefined,
  locationId: undefined,
  isOpen: false,
  closeModal: () => {},
  onSuccess: undefined,
};

export default BulkPowerStateModal;
