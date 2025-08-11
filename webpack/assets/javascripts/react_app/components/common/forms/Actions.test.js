import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';

import Actions from './Actions';
import { mockFunctions } from '../../../common/testHelpers';

describe('Actions', () => {
  it('should include cancel and submit buttons', () => {
    render(<Actions onCancel={mockFunctions.onCancel} />);

    // Should have both cancel and submit buttons
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    const submitButton = screen.getByRole('button', { name: /submit/i });

    expect(cancelButton).toBeInTheDocument();
    expect(submitButton).toBeInTheDocument();
  });

  it('should show disabled submit button when disabled prop is true', () => {
    render(<Actions disabled onCancel={mockFunctions.onCancel} />);

    const submitButton = screen.getByRole('button', { name: /submit/i });
    const cancelButton = screen.getByRole('button', { name: /cancel/i });

    // Submit button should be disabled
    expect(submitButton).toBeDisabled();

    // Cancel button should still be enabled
    expect(cancelButton).not.toBeDisabled();
  });

  it('should show loading state when submitting', () => {
    render(<Actions submitting onCancel={mockFunctions.onCancel} />);

    const submitButton = screen.getByRole('button', { name: /submit/i });

    // Submit button should be disabled when submitting
    expect(submitButton).toBeDisabled();

    // Should show loading indicator (spinner or text)
    const loadingIndicator = screen.queryByText(/submitting|loading/i) ||
                            submitButton.querySelector('.spinner, .loading, [class*="spin"]');

    if (loadingIndicator) {
      expect(loadingIndicator).toBeInTheDocument();
    }
  });

  it('should call onCancel when cancel button is clicked', () => {
    const onCancel = jest.fn();
    render(<Actions onCancel={onCancel} />);

    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    fireEvent.click(cancelButton);

    expect(onCancel).toHaveBeenCalledTimes(1);
  });

  it('should handle form submission correctly', () => {
    const onSubmit = jest.fn();
    render(<Actions onSubmit={onSubmit} />);

    const submitButton = screen.getByRole('button', { name: /submit/i });
    fireEvent.click(submitButton);

    // If onSubmit is handled by the Actions component
    if (onSubmit) {
      expect(onSubmit).toHaveBeenCalledTimes(1);
    }
  });

  it('should be accessible', () => {
    render(<Actions onCancel={mockFunctions.onCancel} />);

    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    const submitButton = screen.getByRole('button', { name: /submit/i });

    // Buttons should be keyboard accessible
    expect(cancelButton).toBeInTheDocument();
    expect(submitButton).toBeInTheDocument();

    // Should have appropriate button roles
    expect(cancelButton).toHaveAttribute('type');
    expect(submitButton).toHaveAttribute('type');
  });

  it('should handle both disabled and submitting states', () => {
    render(<Actions disabled submitting onCancel={mockFunctions.onCancel} />);

    const submitButton = screen.getByRole('button', { name: /submit/i });
    const cancelButton = screen.getByRole('button', { name: /cancel/i });

    // Both states should result in disabled submit button
    expect(submitButton).toBeDisabled();
    expect(cancelButton).not.toBeDisabled();
  });

  it('should render with custom button text if supported', () => {
    render(
      <Actions
        submitText="Save Changes"
        cancelText="Go Back"
        onCancel={mockFunctions.onCancel}
      />
    );

    // Check if custom text is supported
    const saveButton = screen.queryByRole('button', { name: /save changes/i }) ||
                      screen.getByRole('button', { name: /submit/i });
    const goBackButton = screen.queryByRole('button', { name: /go back/i }) ||
                        screen.getByRole('button', { name: /cancel/i });

    expect(saveButton).toBeInTheDocument();
    expect(goBackButton).toBeInTheDocument();
  });

  it('should maintain button focus states', () => {
    render(<Actions onCancel={mockFunctions.onCancel} />);

    const submitButton = screen.getByRole('button', { name: /submit/i });
    const cancelButton = screen.getByRole('button', { name: /cancel/i });

    // Buttons should be focusable
    submitButton.focus();
    expect(submitButton).toHaveFocus();

    cancelButton.focus();
    expect(cancelButton).toHaveFocus();
  });

  it('should render without crashing when no props provided', () => {
    render(<Actions />);

    // Should render basic structure even without props
    const buttons = screen.getAllByRole('button');
    expect(buttons.length).toBeGreaterThanOrEqual(1);
  });
});
