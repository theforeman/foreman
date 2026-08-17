import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom/extend-expect';

import {
  passwordStrengthDataWithVerify,
  passwordStrengthDataWithInputIds,
  passwordStrengthDefaultProps,
} from '../PasswordStrength.fixtures';

import PasswordStrength from '../PasswordStrength';

const defaultProps = {
  updatePassword: jest.fn(),
  updatePasswordConfirmation: jest.fn(),
  ...passwordStrengthDefaultProps,
};

describe('PasswordStrength component', () => {
  beforeEach(() => {
    jest
      .spyOn(document, 'getElementById')
      .mockImplementation(id => ({ value: id }));
  });

  afterEach(() => jest.clearAllMocks());

  it('renders the password label', () => {
    render(<PasswordStrength {...defaultProps} />);

    expect(screen.getByText('Password')).toBeInTheDocument();
  });

  it('renders the password input', () => {
    render(<PasswordStrength {...defaultProps} />);

    const input = document.querySelector(`input#${defaultProps.data.id}`);
    expect(input).toBeInTheDocument();
  });

  it('does not render the verify field when verify is not provided', () => {
    render(<PasswordStrength {...defaultProps} />);

    expect(screen.queryByText('Verify')).not.toBeInTheDocument();
  });

  it('renders the verify field when verify data is provided', () => {
    render(
      <PasswordStrength
        {...defaultProps}
        data={passwordStrengthDataWithVerify}
      />
    );

    expect(screen.getByText('Verify')).toBeInTheDocument();
    expect(
      document.querySelector('input#password_confirmation')
    ).toBeInTheDocument();
  });

  it('shows password error when password is not present', () => {
    render(
      <PasswordStrength {...defaultProps} passwordPresent={false} />
    );

    expect(
      screen.getByText(defaultProps.data.error)
    ).toBeInTheDocument();
  });

  it('shows "Passwords do not match" when passwords do not match', () => {
    render(
      <PasswordStrength
        {...defaultProps}
        doesPasswordsMatch={false}
        data={passwordStrengthDataWithVerify}
      />
    );

    expect(screen.getByText('Passwords do not match')).toBeInTheDocument();
  });

  it('shows verify error when passwords match', () => {
    render(
      <PasswordStrength
        {...defaultProps}
        doesPasswordsMatch
        data={passwordStrengthDataWithVerify}
      />
    );

    expect(
      screen.getByText(passwordStrengthDataWithVerify.verify.error)
    ).toBeInTheDocument();
  });

  it('calls updatePassword when password input changes', async () => {
    render(<PasswordStrength {...defaultProps} />);

    const input = document.querySelector(`input#${defaultProps.data.id}`);
    await userEvent.type(input, 'some-value');

    expect(defaultProps.updatePassword).toHaveBeenLastCalledWith('some-value');
  });

  it('calls updatePasswordConfirmation when confirmation input changes', async () => {
    render(
      <PasswordStrength
        {...defaultProps}
        data={passwordStrengthDataWithVerify}
      />
    );

    const input = document.querySelector('input#password_confirmation');
    await userEvent.type(input, 'some-value');

    expect(defaultProps.updatePasswordConfirmation).toHaveBeenLastCalledWith(
      'some-value'
    );
  });

  it('reads user input values from DOM when userInputIds are provided', () => {
    render(
      <PasswordStrength
        {...defaultProps}
        data={passwordStrengthDataWithInputIds}
      />
    );

    expect(document.getElementById).toHaveBeenCalledWith('input1');
    expect(document.getElementById).toHaveBeenCalledWith('input2');
  });
});
