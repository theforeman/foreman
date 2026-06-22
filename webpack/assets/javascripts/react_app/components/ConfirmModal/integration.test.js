import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';

import { rtlHelpers } from '../../common/rtlTestHelpers';
import ConfirmModal, { openConfirmModal } from './index';

const defaultModalOptions = {
  title: 'Delete host',
  message: 'Are you sure you want to delete this host?',
};

const openModal = (options = {}) => {
  const onConfirm = jest.fn();
  const onCancel = jest.fn();

  const renderResult = rtlHelpers.renderWithStore(<ConfirmModal />);
  const { store } = renderResult;

  store.dispatch(
    openConfirmModal({
      ...defaultModalOptions,
      onConfirm,
      onCancel,
      ...options,
    })
  );

  return { store, onConfirm, onCancel };
};

describe('ConfirmModal integration', () => {
  it('displays title and message when opened via Redux', () => {
    openModal();

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText(defaultModalOptions.title)).toBeInTheDocument();
    expect(screen.getByText(defaultModalOptions.message)).toBeInTheDocument();
  });

  it('calls onConfirm and closes when Confirm is clicked', () => {
    const { onConfirm } = openModal();

    fireEvent.click(screen.getByRole('button', { name: 'Confirm' }));

    expect(onConfirm).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('calls onCancel and closes when Cancel is clicked', () => {
    const { onConfirm, onCancel } = openModal();

    fireEvent.click(screen.getByRole('button', { name: 'Cancel' }));

    expect(onCancel).toHaveBeenCalledTimes(1);
    expect(onConfirm).not.toHaveBeenCalled();
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('renders custom confirm button text when confirmButtonText is provided', () => {
    openModal({ confirmButtonText: 'Delete host' });

    expect(
      screen.getByRole('button', { name: 'Delete host' })
    ).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'Confirm' })
    ).not.toBeInTheDocument();
  });

  describe('isWarning', () => {
    it('renders confirm button with danger variant and warning title icon', () => {
      openModal({ isWarning: true });

      const confirmButton = screen.getByRole('button', { name: 'Confirm' });

      expect(confirmButton).toHaveClass('pf-m-danger');
      expect(
        screen
          .getByRole('dialog')
          .querySelector('.pf-v5-c-modal-box__title-icon')
      ).toBeInTheDocument();
      expect(screen.getByText('Warning alert:')).toBeInTheDocument();
    });
  });

  describe('isDireWarning', () => {
    const direWarningLabel = 'I understand that this action cannot be undone.';

    it('shows acknowledgment checkbox and disables confirm until checked', () => {
      openModal({ isDireWarning: true });

      expect(
        document.querySelector(
          '[data-ouia-component-id="dire-warning-checkbox"]'
        )
      ).toBeInTheDocument();
      expect(screen.getByLabelText(direWarningLabel)).not.toBeChecked();
      expect(screen.getByRole('button', { name: 'Confirm' })).toBeDisabled();
    });

    it('enables confirm and runs onConfirm after acknowledgment is checked', () => {
      const { onConfirm } = openModal({ isDireWarning: true });

      fireEvent.click(screen.getByLabelText(direWarningLabel));

      expect(screen.getByRole('button', { name: 'Confirm' })).toBeEnabled();

      fireEvent.click(screen.getByRole('button', { name: 'Confirm' }));

      expect(onConfirm).toHaveBeenCalledTimes(1);
      expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    });
  });
});
