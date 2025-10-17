import React from 'react';
import { screen, fireEvent, render, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import SubmitOrCancel from './SubmitOrCancel';
import SubmitBtn from './SubmitBtn';
import CancelBtn from './CancelBtn';

// Helper functions for creating props
const createHandlers = () => ({
  submitProps: {
    submitBtnProps: {
      variant: 'primary',
      btnText: 'Confirm',
    },
    cancelBtnProps: {
      variant: 'danger',
      btnText: 'Deny',
    },
  },
  onCancel: jest.fn(),
  onSubmit: jest.fn(),
  id: 'test-modal',
});

const createBaseProps = (isSubmitting = false) => ({
  isSubmitting,
  ...createHandlers(),
});

const fixtures = {
  render: createBaseProps(false),
  whenSubmitting: createBaseProps(true),
};

const createSubmitBtnProps = (isSubmitting = false) => ({
  ...fixtures.render.submitProps.submitBtnProps,
  ...createHandlers(),
  isSubmitting,
});

const createCancelBtnProps = (isSubmitting = false) => ({
  ...fixtures.render.submitProps.cancelBtnProps,
  ...createHandlers(),
  isSubmitting,
});

describe('SubmitOrCancel', () => {
  it('renders', () => {
    render(<SubmitOrCancel {...fixtures.render} />);
    expect(screen.getByRole('button', { name: /submit/i })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /cancel/i })).toBeInTheDocument();
  });

  it('renders when submitting', () => {
    render(<SubmitOrCancel {...fixtures.whenSubmitting} />);

    expect(screen.getByRole('button', { name: /submit/i })).toBeDisabled();
    expect(screen.getByRole('button', { name: /cancel/i })).toBeDisabled();
  });

  describe('SubmitBtn', () => {
    it('renders', () => {
      render(<SubmitBtn {...createSubmitBtnProps()} />);
      expect(screen.getByRole('button', { name: /Confirm/i })).toBeInTheDocument();
    });
  });

  describe('CancelBtn', () => {
    it('renders', () => {
      render(<CancelBtn {...createCancelBtnProps()} />);
      expect(screen.getByRole('button', { name: /Deny/i })).toBeInTheDocument();
    });
  });
});
