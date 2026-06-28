import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import {
  dateTimeWithErrorProps,
  textFieldWithHelpProps,
  formAutocompleteDataProps,
} from '../FormField.fixtures';
import FormField from '../FormField';

// Stub InputFactory so FormField's own wiring (label, type, validation) can be
// asserted without rendering each concrete input (date pickers, autocomplete…).
jest.mock('../InputFactory', () => props => (
  <div
    data-testid="input-factory"
    data-type={props.type}
    data-name={props.name}
  />
));

const inputFactory = () => screen.getByTestId('input-factory');

describe('FormField', () => {
  it.each([
    ['text', 'a'],
    ['date', 'a'],
    ['time', 'a'],
    ['dateTime', 'a'],
  ])('renders an InputFactory for type %s', (type, name) => {
    render(<FormField type={type} name={name} />);

    expect(inputFactory()).toHaveAttribute('data-type', type);
    expect(inputFactory()).toHaveAttribute('data-name', name);
  });

  it('renders the label and label help', () => {
    const { container } = render(<FormField {...textFieldWithHelpProps} />);

    expect(screen.getByText('textField')).toBeInTheDocument();
    expect(container.querySelector('.field-help')).toBeInTheDocument();
    expect(inputFactory()).toHaveAttribute('data-type', 'text');
  });

  it('renders the error message and sets the error validation state', () => {
    const { container } = render(<FormField {...dateTimeWithErrorProps} />);

    expect(screen.getByText('DateTime with error')).toBeInTheDocument();
    expect(screen.getByText('can not be in the past')).toBeInTheDocument();
    expect(container.querySelector('.form-group')).toHaveClass('has-error');
  });

  it('renders an autocomplete InputFactory', () => {
    render(<FormField type="autocomplete" {...formAutocompleteDataProps} />);

    expect(inputFactory()).toHaveAttribute('data-type', 'autocomplete');
  });
});
