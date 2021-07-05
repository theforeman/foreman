import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Modal, Button, ModalVariant } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import { closeConfirmModal, selectConfirmModal } from './slice';

const ConfirmModal = () => {
  const {
    isOpen,
    title,
    message,
    confirmButtonText,
    onConfirm,
    onCancel,
    modalProps,
    isWarning,
  } = useSelector(selectConfirmModal);

  const dispatch = useDispatch();

  const closeModal = () => dispatch(closeConfirmModal());

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
    >
      {confirmButtonText || __('Confirm')}
    </Button>,
    <Button key="cancel" variant="link" onClick={handleCancel}>
      {__('Cancel')}
    </Button>,
  ];

  return (
    <Modal
      id="app-confirm-modal"
      aria-label="application confirm modal"
      variant={ModalVariant.small}
      title={title}
      isOpen={isOpen}
      onClose={closeModal}
      actions={actions}
      titleIconVariant={isWarning ? 'warning' : null}
      {...modalProps}
    >
      {message}
    </Modal>
  );
};

export default ConfirmModal;

export * from './slice';
