import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import ImpersonateIcon from './ImpersonateIcon';

// Render the tooltip content inline (instead of through the Popper, whose async
// updates fire after the click handler and trip the strict console.error setup)
// so the tooltip copy stays under test.
jest.mock('@patternfly/react-core', () => ({
  ...jest.requireActual('@patternfly/react-core'),
  Tooltip: ({ content, children }) => (
    <>
      <div data-testid="tooltip-content">{content}</div>
      {children}
    </>
  ),
}));

const modalText =
  'You are about to stop impersonating other user. Are you sure?';

const renderIcon = (stopImpersonating = () => {}) =>
  render(
    <ImpersonateIcon
      stopImpersonationUrl="/stop_impersonation"
      stopImpersonating={stopImpersonating}
    />
  );

describe('ImpersonateIcon', () => {
  it('renders the icon with the confirmation modal closed', () => {
    const { container } = renderIcon();

    expect(container.querySelector('span.nav-item-iconic')).toBeInTheDocument();
    // the icon carries the impersonation tooltip copy
    expect(screen.getByTestId('tooltip-content')).toHaveTextContent(
      'You are impersonating another user, click to stop the impersonation'
    );
    expect(screen.queryByText(modalText)).not.toBeInTheDocument();
  });

  it('opens the confirmation modal when the icon is clicked', async () => {
    const { container } = renderIcon();

    await userEvent.click(container.querySelector('span.nav-item-iconic'));

    expect(screen.getByText(modalText)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Confirm' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
  });

  it('calls stopImpersonating with the url when confirmed', async () => {
    const stopImpersonating = jest.fn();
    const { container } = renderIcon(stopImpersonating);

    await userEvent.click(container.querySelector('span.nav-item-iconic'));
    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }));

    expect(stopImpersonating).toHaveBeenCalledTimes(1);
    expect(stopImpersonating).toHaveBeenCalledWith('/stop_impersonation');
  });
});
