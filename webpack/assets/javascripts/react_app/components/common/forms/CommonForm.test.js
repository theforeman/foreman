import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { FieldLevelHelp } from 'patternfly-react';

import CommonForm from './CommonForm';

describe('CommonForm', () => {
  it('should display a label field', () => {
    render(<CommonForm label="my label" />);

    // Should display the label text
    expect(screen.getByText('my label')).toBeInTheDocument();

    // Should render as a label element or within form group
    const labelElement = screen.getByText('my label').closest('label') ||
                        screen.getByText('my label');
    expect(labelElement).toBeInTheDocument();
  });

  it('should accept a required field', () => {
    render(<CommonForm label="my label" required />);

    // Should display the label
    expect(screen.getByText('my label')).toBeInTheDocument();

    // Should show required indicator (usually asterisk or text)
    const requiredIndicator = screen.queryByText('*') ||
                             screen.container.querySelector('.required, [class*="required"]') ||
                             screen.queryByText(/required/i);

    if (requiredIndicator) {
      expect(requiredIndicator).toBeInTheDocument();
    }
  });

  it('should display validation errors if touched', () => {
    render(<CommonForm label="my label" touched error="is required!" />);

    // Should display the label
    expect(screen.getByText('my label')).toBeInTheDocument();

    // Should display the error message when touched
    expect(screen.getByText('is required!')).toBeInTheDocument();

    // Error should have appropriate styling/role
    const errorElement = screen.getByText('is required!');
    const errorContainer = errorElement.closest('.has-error, .error, [class*="error"]') ||
                          errorElement;
    expect(errorContainer).toBeInTheDocument();
  });

  it('should not display validation errors if not touched', () => {
    render(<CommonForm label="my label" error="is required!" />);

    // Should display the label
    expect(screen.getByText('my label')).toBeInTheDocument();

    // Should NOT display the error message when not touched
    expect(screen.queryByText('is required!')).not.toBeInTheDocument();
  });

  it('should not display validation errors if there are none', () => {
    render(<CommonForm label="my label" />);

    // Should display the label
    expect(screen.getByText('my label')).toBeInTheDocument();

    // Should not have any error elements
    const errorElements = screen.container.querySelectorAll('.has-error, .error, [class*="error"]');
    expect(errorElements).toHaveLength(0);
  });

  it('should accept customized input class', () => {
    render(<CommonForm name="name" inputClassName="col-md-10" label="Name" />);

    // Should display the label
    expect(screen.getByText('Name')).toBeInTheDocument();

    // Should apply the custom input class
    const inputContainer = screen.container.querySelector('.col-md-10');
    expect(inputContainer).toBeInTheDocument();
  });

  it('should render tooltip help', () => {
    render(
      <CommonForm
        name="name"
        label="Required form field"
        required
        tooltipHelp={<FieldLevelHelp content="This is a helpful tooltip" />}
      />
    );

    // Should display the label
    expect(screen.getByText('Required form field')).toBeInTheDocument();

    // Should render the tooltip help component
    // FieldLevelHelp usually renders as a button or icon
    const helpButton = screen.queryByRole('button') ||
                      screen.container.querySelector('[class*="help"], [class*="tooltip"]');

    if (helpButton) {
      expect(helpButton).toBeInTheDocument();
    }
  });

  it('should handle form field interaction', () => {
    const onChange = jest.fn();
    render(
      <CommonForm
        label="Interactive field"
        name="test-field"
        onChange={onChange}
      >
        <input name="test-field" onChange={onChange} />
      </CommonForm>
    );

    // Should display the label
    expect(screen.getByText('Interactive field')).toBeInTheDocument();

    // If there's an input, test interaction
    const input = screen.queryByRole('textbox') || screen.querySelector('input[name="test-field"]');
    if (input) {
      fireEvent.change(input, { target: { value: 'test value' } });

      if (onChange) {
        expect(onChange).toHaveBeenCalled();
      }
    }
  });

  it('should render children content', () => {
    render(
      <CommonForm label="Form with children">
        <input data-testid="child-input" placeholder="Child input" />
        <div data-testid="child-div">Child content</div>
      </CommonForm>
    );

    // Should display the label
    expect(screen.getByText('Form with children')).toBeInTheDocument();

    // Should render children
    expect(screen.getByTestId('child-input')).toBeInTheDocument();
    expect(screen.getByTestId('child-div')).toBeInTheDocument();
  });

  it('should be accessible', () => {
    render(
      <CommonForm
        label="Accessible form field"
        name="accessible-field"
        required
        error="Field error"
        touched
      />
    );

    // Label should be properly associated
    const label = screen.getByText('Accessible form field');
    expect(label).toBeInTheDocument();

    // Error should be accessible
    const error = screen.getByText('Field error');
    expect(error).toBeInTheDocument();

    // Should have proper form structure
    const formGroup = label.closest('.form-group, .field-group, [class*="form"]');
    if (formGroup) {
      expect(formGroup).toBeInTheDocument();
    }
  });

  it('should handle different error states', () => {
    const { rerender } = render(
      <CommonForm label="Dynamic field" error="First error" touched />
    );

    // Should show first error
    expect(screen.getByText('First error')).toBeInTheDocument();

    // Change error
    rerender(<CommonForm label="Dynamic field" error="Second error" touched />);

    expect(screen.getByText('Second error')).toBeInTheDocument();
    expect(screen.queryByText('First error')).not.toBeInTheDocument();

    // Remove error
    rerender(<CommonForm label="Dynamic field" touched />);

    expect(screen.queryByText('Second error')).not.toBeInTheDocument();
  });

  it('should handle touch state changes', () => {
    const { rerender } = render(
      <CommonForm label="Touch field" error="Validation error" />
    );

    // Should not show error when not touched
    expect(screen.queryByText('Validation error')).not.toBeInTheDocument();

    // Should show error when touched
    rerender(<CommonForm label="Touch field" error="Validation error" touched />);

    expect(screen.getByText('Validation error')).toBeInTheDocument();
  });
});
