import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Modal, Button, ModalVariant, Checkbox } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import { closeConfirmModal, selectConfirmModal } from './slice';

const ConfirmModal = () => {
  const {
    id,
    isOpen,
    title,
    message,
    confirmButtonText,
    onConfirm,
    onCancel,
    modalProps,
    isWarning,
    isDireWarning,
  } = useSelector(selectConfirmModal);

  const dispatch = useDispatch();
  const [direWarningChecked, setDireWarningChecked] = useState(false);

  const closeModal = () => {
    setDireWarningChecked(false);
    return dispatch(closeConfirmModal());
  };

  const handleCancel = () => {
    onCancel();
    closeModal();
  };

  const handleConfirm = () => {
    onConfirm();
    closeModal();
  };

  const actions = [
    <Button
      key="confirm"
      variant={isWarning ? 'danger' : 'primary'}
      onClick={handleConfirm}
      ouiaId="btn-modal-confirm"
      isDisabled={isDireWarning && !direWarningChecked}
    >
      {confirmButtonText || __('Confirm')}
    </Button>,
    <Button
      key="cancel"
      variant="link"
      onClick={handleCancel}
      ouiaId="btn-modal-cancel"
    >
      {__('Cancel')}
    </Button>,
  ];

  const direWarningCheckbox = (
    <Checkbox
      id="dire-warning-checkbox"
      ouiaId="dire-warning-checkbox"
      label={__('I understand that this action cannot be undone.')}
      isChecked={direWarningChecked}
      onChange={val => setDireWarningChecked(val)}
    />
  );

  if (!isOpen) return null;

  return (
    <Modal
      ouiaId="app-confirm-modal"
      id={id ?? 'app-confirm-modal'}
      aria-label="application confirm modal"
      variant={ModalVariant.small}
      title={title}
      isOpen={isOpen}
      onClose={closeModal}
      actions={actions}
      titleIconVariant={isWarning ? 'warning' : null}
      {...modalProps}
    >
      <>
        {message}
        {isDireWarning && direWarningCheckbox}
      </>
    </Modal>
  );
};

export default ConfirmModal;

export * from './slice';
