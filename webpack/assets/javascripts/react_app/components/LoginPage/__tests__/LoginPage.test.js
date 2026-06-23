import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import LoginPage from '../LoginPage';
import { caption, logoSrc, token } from '../LoginPage.fixtures';

const renderLoginPage = (overrides = {}) => {
  render(
    <LoginPage
      caption={caption}
      logoSrc={logoSrc}
      token={token}
      {...overrides}
    />
  );
};

const getAlertCloseButton = () => screen.queryByRole('button', { name: /^Close/i });

describe('LoginPage', () => {
  it('renders login page', () => {
    renderLoginPage({ alerts: null });

    expect(screen.getByText('Welcome')).toBeInTheDocument();
    expect(screen.getByText('Log in to your account')).toBeInTheDocument();
    expect(screen.getByText('some caption')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Username')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Password')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Log In' })).toBeDisabled();
  });

  it('renders submit error alert', () => {
    renderLoginPage({ alerts: { error: 'some-error' } });

    expect(screen.getByText('some-error')).toBeInTheDocument();
    expect(getAlertCloseButton()).not.toBeInTheDocument();
  });

  it('renders dismissible warning alert', async () => {
    renderLoginPage({ alerts: { warning: 'some-warning' } });

    expect(screen.getByText('some-warning')).toBeInTheDocument();

    await userEvent.click(getAlertCloseButton());

    expect(screen.queryByText('some-warning')).not.toBeInTheDocument();
  });

  it('enables log in when username and password are entered', async () => {
    renderLoginPage({ alerts: null });

    const submitButton = screen.getByRole('button', { name: 'Log In' });
    expect(submitButton).toBeDisabled();

    await userEvent.type(screen.getByPlaceholderText('Username'), 'admin');
    await userEvent.type(screen.getByPlaceholderText('Password'), 'secret');

    expect(submitButton).toBeEnabled();
  });
});
