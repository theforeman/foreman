import React from 'react';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import { rtlHelpers } from '../../../common/rtlTestHelpers';
import { passwords } from '../PasswordStrength.fixtures';
import PasswordStrength from '../index';

const { renderWithStore } = rtlHelpers;

document.getElementById = jest.fn(id => {
  const entry = passwords[id];
  return entry ? { value: entry.password } : null;
});

const renderPasswordStrength = () =>
  renderWithStore(
    <PasswordStrength
      data={{
        className: 'form-control',
        id: 'user_password',
        name: 'user[password]',
        verify: { name: 'user[password_confirmation]' },
        userInputIds: ['username', 'email'],
      }}
    />
  );

describe('PasswordStrength integration test', () => {
  const passwordTestCases = Object.entries(passwords).map(
    ([key, { password, expected }]) => [key, password, expected]
  );

  it.each(passwordTestCases)(
    'displays correct strength for %s password',
    async (_key, password, expected) => {
      const { container } = renderPasswordStrength();
      const passwordInput = container.querySelector('#user_password');

      await userEvent.type(passwordInput, password);

      expect(screen.getByText(expected)).toBeInTheDocument();
    }
  );

  it('shows error when password confirmation does not match', async () => {
    const { container } = renderPasswordStrength();
    const passwordInput = container.querySelector('#user_password');
    const confirmInput = container.querySelector('#password_confirmation');

    await userEvent.type(passwordInput, passwords.veryStrong.password);
    await userEvent.type(confirmInput, passwords.strong.password);

    expect(screen.getByText('Passwords do not match')).toBeInTheDocument();
  });

  it('does not show error when password confirmation matches', async () => {
    const { container } = renderPasswordStrength();
    const passwordInput = container.querySelector('#user_password');
    const confirmInput = container.querySelector('#password_confirmation');

    await userEvent.type(passwordInput, passwords.veryStrong.password);
    await userEvent.type(confirmInput, passwords.veryStrong.password);

    expect(
      screen.queryByText('Passwords do not match')
    ).not.toBeInTheDocument();
  });
});
