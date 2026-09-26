import React from 'react';
import { IntlProvider } from 'react-intl';
import { fireEvent, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import PersonalAccessToken from './PersonalAccessToken';

const token = {
  id: 1,
  name: 'automation',
  created_at: '2026-01-01T00:00:00Z',
  expires_at: '2026-02-01T00:00:00Z',
  last_used_at: null,
  user_id: 1,
  'revoked?': true,
  'active?': false,
};

test('allows an inactive personal access token to be deleted', () => {
  const deletePersonalAccessToken = jest.fn();
  render(
    <IntlProvider
      locale="en"
      initialNow={new Date('2026-03-01T00:00:00Z')}
      timeZone="UTC"
    >
      <table>
        <tbody>
          <PersonalAccessToken
            {...token}
            deletable
            deletePersonalAccessToken={deletePersonalAccessToken}
          />
        </tbody>
      </table>
    </IntlProvider>
  );

  fireEvent.click(screen.getByRole('button', { name: 'Delete' }));

  expect(deletePersonalAccessToken).toHaveBeenCalledWith(token.id);
  expect(screen.queryByRole('button', { name: 'Revoke' })).not.toBeInTheDocument();
});
