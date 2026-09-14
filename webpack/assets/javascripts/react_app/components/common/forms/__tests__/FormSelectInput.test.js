import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import FormSelectInput from '../FormSelectInput';
import { selectProps } from '../FormField.fixtures';

describe('FormSelectInput', () => {
  it('renders grouped options with a label when provided', () => {
    render(<FormSelectInput {...selectProps} onChange={jest.fn()} />);

    expect(screen.getByText('Grouped select')).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Ungrouped true' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Group2 opt2' })).toBeInTheDocument();
  });

  it('renders without FormGroup when label is omitted', () => {
    const { label, ...propsWithoutLabel } = selectProps;

    render(
      <FormSelectInput {...propsWithoutLabel} onChange={jest.fn()} />
    );

    expect(screen.queryByText(label)).not.toBeInTheDocument();
    expect(screen.getByRole('combobox')).toBeInTheDocument();
  });
});
