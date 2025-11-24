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
import { failedHostsToastParams } from '../helpers';
import { addToast } from '../../../ToastsList/slice';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from '../../../../routes/Hosts/constants';
import { foremanUrl } from '../../../../common/helpers';
import { APIActions } from '../../../../redux/API';

const BulkPowerStateModal = ({
  selectedHostsCount,
  fetchBulkParams,
  isOpen,
  closeModal,
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
    dispatch(
      APIActions.get({
        key: API_REQUEST_KEY,
        url: foremanUrl(HOSTS_API_PATH),
      })
    );

    cleanup();
  };

  const handleError = error => {
    const apiError = error?.response?.data?.error;

    if (apiError) {
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
    }

    cleanup();
  };

  const handleSubmit = () => {
    setIsLoading(true);
    const payload = {
      included: {
        search: fetchBulkParams(),
      },
      power: selectedPowerState,
    };
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
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
};

BulkPowerStateModal.defaultProps = {
  selectedHostsCount: 0,
  isOpen: false,
  closeModal: () => {},
};

export default BulkPowerStateModal;
