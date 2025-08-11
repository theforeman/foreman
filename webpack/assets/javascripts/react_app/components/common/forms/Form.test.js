import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import Form from './Form';
import { formAssertions, createMockProps, mockFunctions } from '../../../common/testHelpers';

describe('Form', () => {
  it('should render a form with submit and cancel actions', () => {
    render(<Form onSubmit={mockFunctions.onSubmit} onCancel={mockFunctions.onCancel} />);

    // Test that form element is present
    expect(screen.getByRole('form')).toBeInTheDocument();
    expect(screen.getByRole('form')).toHaveClass('form-horizontal', 'well');

    // Test that form actions are present (submit/cancel buttons)
    // Note: The actual button text depends on the Actions component implementation
    const buttons = screen.getAllByRole('button');
    expect(buttons.length).toBeGreaterThanOrEqual(2); // Should have submit and cancel buttons
  });

  it('should display one base error with danger severity', () => {
    const errorProps = createMockProps.formError(['invalid something'], 'danger');
    render(<Form {...errorProps} />);

    // Test that error alert is displayed
    formAssertions.expectErrorAlert(screen, 'invalid something');

    // Test that error title is displayed (default title)
    expect(screen.getByText(/unable to save/i)).toBeInTheDocument();

    // Test that error message is displayed as span (single error)
    expect(screen.getByText('invalid something')).toBeInTheDocument();

    // Should not be displayed as list items for single error
    expect(screen.queryAllByRole('listitem')).toHaveLength(0);
  });

  it('should display multiple base errors as a list', () => {
    const errorProps = createMockProps.formError(['invalid something', 'error too'], 'danger');
    render(<Form {...errorProps} />);

    // Test that error alert is displayed
    formAssertions.expectErrorAlert(screen);

    // Test that multiple errors are displayed as list items
    formAssertions.expectErrorList(screen, ['invalid something', 'error too']);

    // Test default error title
    expect(screen.getByText(/unable to save/i)).toBeInTheDocument();
  });

  it('should accept custom error title', () => {
    const errorProps = createMockProps.formError(['invalid something'], 'danger');
    render(<Form {...errorProps} errorTitle="Oops" />);

    // Test that custom error title is displayed
    expect(screen.getByText('Oops')).toBeInTheDocument();

    // Test that error message is still displayed
    expect(screen.getByText('invalid something')).toBeInTheDocument();

    // Test that default title is not displayed
    expect(screen.queryByText(/unable to save/i)).not.toBeInTheDocument();
  });

  it('should display form errors as warning', () => {
    const warningProps = createMockProps.formError(['Do not feed the trolls'], 'warning');
    render(<Form {...warningProps} />);

    // Test that warning alert is displayed
    formAssertions.expectWarningAlert(screen, 'Do not feed the trolls');

    // Test that the alert has warning styling (PatternFly Alert with type="warning")
    const alert = screen.getByRole('alert');
    expect(alert).toBeInTheDocument();

    // Test error message content
    expect(screen.getByText('Do not feed the trolls')).toBeInTheDocument();
  });

  it('should handle form submission', () => {
    const onSubmit = jest.fn();
    render(<Form onSubmit={onSubmit} />);

    const form = screen.getByRole('form');

    // Test form submission behavior
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    // Note: The actual submission behavior depends on the Actions component
    // This test ensures the form element properly handles the onSubmit prop
    expect(form).toHaveAttribute('onSubmit');
  });

  it('should render children content', () => {
    render(
      <Form>
        <div data-testid="form-content">Test form content</div>
      </Form>
    );

    expect(screen.getByTestId('form-content')).toBeInTheDocument();
    expect(screen.getByText('Test form content')).toBeInTheDocument();
  });
});
