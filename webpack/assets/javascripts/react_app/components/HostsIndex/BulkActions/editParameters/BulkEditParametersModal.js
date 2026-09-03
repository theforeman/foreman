import React, { useEffect, useMemo, useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  Modal,
  ModalVariant,
  Button,
  Form,
  FormGroup,
  TextInput,
  TextContent,
  Text,
} from '@patternfly/react-core';
import { TypeaheadSelect } from '@patternfly/react-templates';
import { addToast } from '../../../ToastsList/slice';
import { translate as __, sprintf } from '../../../../common/I18n';
import { STATUS } from '../../../../constants';
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../../../redux/API/APISelectors';
import { buildBulkRequestBody, bulkErrorToastParams } from '../helpers';
import SkeletonLoader from '../../../common/SkeletonLoader';
import { bulkUpdateParameters, fetchCommonParameters } from './actions';
import { BULK_UPDATE_PARAMETERS_KEY, COMMON_PARAMETERS_KEY } from './constants';

const BulkEditParametersModal = ({
  selectedCount,
  fetchBulkParams,
  organizationId,
  locationId,
  isOpen,
  closeModal,
  onSuccess: onSuccessCallback,
}) => {
  const dispatch = useDispatch();
  const [parameterName, setParameterName] = useState('');
  const [parameterValue, setParameterValue] = useState('');

  const commonParameters = useSelector(state =>
    selectAPIResponse(state, COMMON_PARAMETERS_KEY)
  );
  const parametersStatus =
    useSelector(state => selectAPIStatus(state, COMMON_PARAMETERS_KEY)) ||
    STATUS.PENDING;
  const updateStatus = useSelector(state =>
    selectAPIStatus(state, BULK_UPDATE_PARAMETERS_KEY)
  );

  useEffect(() => {
    if (isOpen) {
      dispatch(fetchCommonParameters());
    }
  }, [dispatch, isOpen]);

  const handleModalClose = () => {
    setParameterName('');
    setParameterValue('');
    closeModal();
  };

  const handleSuccess = response => {
    dispatch(
      addToast({
        type: 'success',
        message: response.data.message,
      })
    );
    if (onSuccessCallback) onSuccessCallback();
    handleModalClose();
  };

  const handleError = error => {
    dispatch(addToast(bulkErrorToastParams(error, BULK_UPDATE_PARAMETERS_KEY)));
    handleModalClose();
  };

  const handleSubmit = () => {
    const requestBody = buildBulkRequestBody({
      fetchBulkParams,
      organizationId,
      locationId,
      name: parameterName,
      value: parameterValue,
    });
    dispatch(bulkUpdateParameters(requestBody, handleSuccess, handleError));
  };

  const selectOptions = useMemo(
    () =>
      (commonParameters?.results || []).map(param => ({
        content: param.name,
        value: param.name,
      })),
    [commonParameters]
  );

  const isSubmitting = updateStatus === STATUS.PENDING;
  const isConfirmDisabled =
    isSubmitting ||
    parametersStatus !== STATUS.RESOLVED ||
    !parameterName ||
    parameterValue === '';

  return (
    <Modal
      variant={ModalVariant.small}
      title={__('Set parameters')}
      isOpen={isOpen}
      onClose={handleModalClose}
      ouiaId="bulk-set-parameters-modal"
      aria-labelledby="bulk-set-parameters-modal"
      actions={[
        <Button
          key="confirm"
          variant="primary"
          onClick={handleSubmit}
          isDisabled={isConfirmDisabled}
          isLoading={isSubmitting}
          spinnerAriaLabel={__('Loading')}
          ouiaId="bulk-set-parameters-confirm"
        >
          {__('Confirm')}
        </Button>,
        <Button
          key="cancel"
          variant="link"
          onClick={handleModalClose}
          isDisabled={isSubmitting}
          ouiaId="bulk-set-parameters-cancel"
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      <TextContent className="pf-v5-u-mb-md">
        <Text component="p" ouiaId="bulk-set-parameters-hosts-count">
          <FormattedMessage
            id="bulk-set-parameters-description"
            defaultMessage="Set a host parameter override on {boldCount} selected {count, plural, one {host} other {hosts}}."
            values={{
              count: selectedCount,
              boldCount: <strong>{selectedCount}</strong>,
            }}
          />
        </Text>
        <Text
          component="small"
          className="pf-v5-u-color-200"
          ouiaId="bulk-set-parameters-explanation"
        >
          {__(
            'Select a global parameter and a value. Hosts that already have this parameter will be updated; others will get a new host override.'
          )}
        </Text>
      </TextContent>
      <SkeletonLoader status={parametersStatus} skeletonProps={{ count: 2 }}>
        <Form>
          <FormGroup
            label={__('Parameter')}
            fieldId="bulk-set-parameter-name"
            isRequired
          >
            <TypeaheadSelect
              id="bulk-set-parameter-name"
              selected={parameterName}
              selectOptions={selectOptions}
              placeholder={__('Select a global parameter')}
              noOptionsFoundMessage={filter =>
                filter
                  ? sprintf(__('No results found for %s'), filter)
                  : __('No global parameters found')
              }
              onClearSelection={() => setParameterName('')}
              onSelect={(_event, value) => setParameterName(value)}
              toggleProps={{
                'aria-label': __('Parameter'),
                ouiaId: 'bulk-set-parameter-select',
                isDisabled: isSubmitting,
              }}
            />
          </FormGroup>
          <FormGroup
            label={__('Value')}
            fieldId="bulk-set-parameter-value"
            isRequired
          >
            <TextInput
              id="bulk-set-parameter-value"
              ouiaId="bulk-set-parameter-value"
              value={parameterValue}
              onChange={(_event, value) => setParameterValue(value)}
              isDisabled={isSubmitting}
              aria-label={__('Value')}
            />
          </FormGroup>
        </Form>
      </SkeletonLoader>
    </Modal>
  );
};

BulkEditParametersModal.propTypes = {
  selectedCount: PropTypes.number,
  fetchBulkParams: PropTypes.func.isRequired,
  organizationId: PropTypes.number,
  locationId: PropTypes.number,
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  onSuccess: PropTypes.func,
};

BulkEditParametersModal.defaultProps = {
  selectedCount: 0,
  organizationId: undefined,
  locationId: undefined,
  isOpen: false,
  closeModal: () => {},
  onSuccess: undefined,
};

export default BulkEditParametersModal;
