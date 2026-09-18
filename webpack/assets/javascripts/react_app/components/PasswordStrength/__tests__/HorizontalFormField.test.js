import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import HorizontalFormField from '../HorizontalFormField';

describe('HorizontalFormField', () => {
  it('renders the label and child control', () => {
    render(
      <HorizontalFormField label="Password">
        <input type="password" aria-label="Password input" />
      </HorizontalFormField>
    );

    expect(screen.getByText('Password')).toBeInTheDocument();
    expect(screen.getByLabelText('Password input')).toBeInTheDocument();
  });

  it('marks required fields in the label', () => {
    render(
      <HorizontalFormField label="Password" required>
        <input type="password" aria-label="Password input" />
      </HorizontalFormField>
    );

    expect(screen.getByText('Password *')).toBeInTheDocument();
  });

  it('shows validation error when touched and error are set', () => {
    render(
      <HorizontalFormField label="Password" touched error="is required">
        <input type="password" aria-label="Password input" />
      </HorizontalFormField>
    );

    expect(screen.getByText('is required')).toBeInTheDocument();
  });

  it('does not show validation error when not touched', () => {
    render(
      <HorizontalFormField label="Password" error="is required">
        <input type="password" aria-label="Password input" />
      </HorizontalFormField>
    );

    expect(screen.queryByText('is required')).not.toBeInTheDocument();
  });

  it('forwards input changes from the child control', () => {
    const handleChange = jest.fn();

    render(
      <HorizontalFormField label="Verify">
        <input
          type="password"
          aria-label="Verify password"
          onChange={handleChange}
        />
      </HorizontalFormField>
    );

    userEvent.type(screen.getByLabelText('Verify password'), 'secret');

    expect(handleChange).toHaveBeenCalled();
  });
});
