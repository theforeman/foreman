import React, { useState } from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import TokenLifeTime from '../../components/fields/TokenLifeTime';

import { tokenLifeTimeProps } from '../fixtures';

describe('RegistrationCommandsPage fields - TokenLifeTime', () => {
  const onChange = jest.fn();
  const handleInvalidField = jest.fn();

  const defaultProps = {
    ...tokenLifeTimeProps,
    onChange,
    handleInvalidField,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders token life time field with default value', () => {
    render(<TokenLifeTime {...defaultProps} />);

    expect(screen.getByText('Token life time')).toBeInTheDocument();
    expect(screen.getByLabelText('Token life time')).toHaveValue(4);
    expect(screen.getByText('hours')).toBeInTheDocument();
    expect(
      screen.getByRole('checkbox', { name: 'unlimited' })
    ).not.toBeChecked();
  });

  it('disables inputs while loading', () => {
    render(<TokenLifeTime {...defaultProps} isLoading />);

    expect(screen.getByLabelText('Token life time')).toBeDisabled();
    expect(screen.getByRole('checkbox', { name: 'unlimited' })).toBeDisabled();
  });

  it('disables the number input when unlimited is selected', () => {
    render(<TokenLifeTime {...defaultProps} value="unlimited" />);

    expect(screen.getByLabelText('Token life time')).toBeDisabled();
    expect(screen.getByRole('checkbox', { name: 'unlimited' })).toBeChecked();
  });

  it('selects unlimited when the checkbox is checked', async () => {
    const TokenLifeTimeWithState = () => {
      const [value, setValue] = useState(defaultProps.value);

      return (
        <TokenLifeTime
          {...defaultProps}
          value={value}
          onChange={setValue}
        />
      );
    };

    render(<TokenLifeTimeWithState />);

    await userEvent.click(screen.getByRole('checkbox', { name: 'unlimited' }));

    expect(screen.getByRole('checkbox', { name: 'unlimited' })).toBeChecked();
    expect(screen.getByLabelText('Token life time')).toBeDisabled();
    expect(handleInvalidField).toHaveBeenCalledWith('Token life time', true);
  });

  it('restores default hours when unlimited is unchecked', async () => {
    const TokenLifeTimeWithState = () => {
      const [value, setValue] = useState('unlimited');

      return (
        <TokenLifeTime
          {...defaultProps}
          value={value}
          onChange={setValue}
        />
      );
    };

    render(<TokenLifeTimeWithState />);

    await userEvent.click(screen.getByRole('checkbox', { name: 'unlimited' }));

    expect(screen.getByRole('checkbox', { name: 'unlimited' })).not.toBeChecked();
    expect(screen.getByLabelText('Token life time')).toHaveValue(4);
    expect(screen.getByLabelText('Token life time')).toBeEnabled();
    expect(handleInvalidField).toHaveBeenCalledWith('Token life time', true);
  });

  it('updates value when the number input changes', async () => {
    render(<TokenLifeTime {...defaultProps} />);

    const input = screen.getByLabelText('Token life time');

    await userEvent.clear(input);
    await userEvent.type(input, '24');

    expect(onChange).toHaveBeenLastCalledWith('24');
    expect(handleInvalidField).toHaveBeenLastCalledWith('Token life time', true);
  });

  it('shows validation error for out of range values', () => {
    render(<TokenLifeTime {...defaultProps} value={0} />);

    expect(
      screen.getByText(
        'Token life time value must be between 1 and 999999 hours.'
      )
    ).toBeInTheDocument();
  });

  it('reports invalid field when value is out of range', async () => {
    render(<TokenLifeTime {...defaultProps} />);

    const input = screen.getByLabelText('Token life time');

    await userEvent.clear(input);
    await userEvent.type(input, '0');

    expect(handleInvalidField).toHaveBeenLastCalledWith(
      'Token life time',
      false
    );
  });

  it('does not show validation error for unlimited value', () => {
    render(<TokenLifeTime {...defaultProps} value="unlimited" />);

    expect(
      screen.queryByText(
        'Token life time value must be between 1 and 999999 hours.'
      )
    ).not.toBeInTheDocument();
  });
});
