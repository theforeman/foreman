import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import FormField from '../FormField';
import {
  dateTimeWithErrorProps,
  textFieldWithHelpProps,
} from '../FormField.fixtures';

describe('FormField', () => {
  it('renders a text input with label', () => {
    render(
      <FormField
        type="text"
        id="text-field"
        name="group[textfield]"
        label="Name"
      />
    );

    expect(screen.getByLabelText('Name')).toBeInTheDocument();
    expect(screen.getByRole('textbox')).toHaveAttribute(
      'name',
      'group[textfield]'
    );
  });

  it('renders label help icon when labelHelp is provided', () => {
    render(<FormField {...textFieldWithHelpProps} />);

    expect(screen.getByText('textField')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Help' })).toBeInTheDocument();
  });

  it('renders server-side validation error', () => {
    render(<FormField {...dateTimeWithErrorProps} />);

    expect(screen.getByText('DateTime with error')).toBeInTheDocument();
    expect(screen.getByText('can not be in the past')).toBeInTheDocument();
    expect(document.querySelector('.form-group.has-error')).toBeInTheDocument();
  });

  it('renders validation warning with warning variant', async () => {
    render(
      <FormField
        type="counter"
        id="counter-field"
        name="host[cpus]"
        label="CPUs"
        value={11}
        recommendedMaxValue={10}
      />
    );

    expect(
      await screen.findByText(/Specified value is higher than recommended maximum 10/)
    ).toBeInTheDocument();
    expect(
      document.querySelector('.form-group.has-warning')
    ).toBeInTheDocument();
    expect(
      document.querySelector('.pf-v5-c-helper-text__item.pf-m-warning')
    ).toBeInTheDocument();
  });

  it('passes error validated state to text inputs', () => {
    render(
      <FormField
        type="text"
        id="error-field"
        name="group[error]"
        label="Field"
        error="Invalid value"
      />
    );

    expect(screen.getByRole('textbox')).toHaveAttribute('aria-invalid', 'true');
    expect(document.querySelector('.form-group.has-error')).toBeInTheDocument();
  });

  it('renders inline help text', () => {
    render(
      <FormField
        type="text"
        id="help-field"
        name="group[help]"
        label="Field"
        helpInline="Some helpful hint"
      />
    );

    expect(screen.getByText('Some helpful hint')).toBeInTheDocument();
  });

  it('marks required fields in the label', () => {
    render(
      <FormField
        type="text"
        id="required-field"
        name="group[required]"
        label="Required field"
        required
      />
    );

    expect(screen.getByText(/Required field/)).toBeInTheDocument();
    expect(
      document.querySelector('label[for="required-field"]')
    ).toHaveTextContent('*');
  });
});
