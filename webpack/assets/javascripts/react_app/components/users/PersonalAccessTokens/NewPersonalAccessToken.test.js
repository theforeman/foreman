import React, { useState } from 'react';
import { fireEvent, screen, render, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import NewPersonalAccessToken from './NewPersonalAccessToken';

describe('New personal access token', () => {

  it('renders the success alert with the token value', async () => {
    const onDismiss = jest.fn();
    await act(async () => {
      render(
        <NewPersonalAccessToken
          onDismiss={onDismiss}
          newPersonalAccessToken="new-secret-token"
        />
      );
    });

    expect(
      screen.getByText('Your New Personal Access Token')
    ).toBeInTheDocument();
    expect(screen.getByText('new-secret-token')).toBeInTheDocument();
    expect(
      screen.getByText(
        /Make sure to copy your new personal access token now/
      )
    ).toBeInTheDocument();
  });

  it('hides the alert after onDismiss clears the token', async () => {
    const Harness = () => {
      const [token, setToken] = useState('visible-token');
      return (
        <NewPersonalAccessToken
          onDismiss={() => setToken(null)}
          newPersonalAccessToken={token}
        />
      );
    };

    render(<Harness />);

    expect(screen.getByText('visible-token')).toBeInTheDocument();

    await act(async () => {
      fireEvent.click(screen.getByRole('button', { name: /close/i }));
    });

    expect(
      screen.queryByText('Your New Personal Access Token')
    ).not.toBeInTheDocument();
    expect(screen.queryByText('visible-token')).not.toBeInTheDocument();
  });
});
