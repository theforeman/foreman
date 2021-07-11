import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { DropdownItem } from '@patternfly/react-core';
import { APIActions } from '../../../../../redux/API';
import { openConfirmModal } from '../../../../ConfirmModal';

export const TableConfirmModal = ({
  disabled,
  label,
  message,
  path,
  isWarning,
  confirmButtonText,
  operation,
  reloadData,
}) => {
  const dispatch = useDispatch();
  const APIKey = `CONFIRM${path}`;
  const handleConfirm = () => {
    dispatch(
      APIActions[operation]({
        key: APIKey,
        url: path,
        successToast: response => response.data.message,
        handleSuccess: reloadData,
      })
    );
  };

  const handleClick = () =>
    dispatch(
      openConfirmModal({
        title: label,
        message,
        onConfirm: handleConfirm,
        isWarning,
        confirmButtonText,
      })
    );

  return (
    <DropdownItem isDisabled={disabled} onClick={handleClick}>
      {label}
    </DropdownItem>
  );
};

TableConfirmModal.propTypes = {
  disabled: PropTypes.bool,
  label: PropTypes.string.isRequired,
  message: PropTypes.string.isRequired,
  path: PropTypes.string.isRequired,
  operation: PropTypes.string.isRequired,
  reloadData: PropTypes.func.isRequired,
  isWarning: PropTypes.bool,
  confirmButtonText: PropTypes.string,
};

TableConfirmModal.defaultProps = {
  disabled: false,
  isWarning: false,
  confirmButtonText: null,
};

export default TableConfirmModal;
