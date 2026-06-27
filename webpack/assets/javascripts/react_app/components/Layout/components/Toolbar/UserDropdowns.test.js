import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import UserDropdowns from './UserDropdowns';
import { userDropdownProps } from '../../Layout.fixtures';

// Drop the `isOpen` override from the fixture so the component's own
// `userDropdownOpen` state drives whether the menu is open.
const { isOpen, ...stateDrivenProps } = userDropdownProps;

describe('UserDropdown', () => {
  it('renders the toggle with the current user name and stays closed initially', () => {
    render(<UserDropdowns {...stateDrivenProps} />);

    // the toggle shows the current user's name
    expect(screen.getByText('G L')).toBeInTheDocument();

    // userDropdownOpen starts false, so no menu items are rendered yet
    expect(screen.queryByRole('menuitem')).not.toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: /G L/ })
    ).toHaveAttribute('aria-expanded', 'false');
  });

  it('opens the dropdown when the toggle is clicked', async () => {
    render(<UserDropdowns {...stateDrivenProps} />);

    const toggle = screen.getByRole('button', { name: /G L/ });
    await userEvent.click(toggle);

    // setUserDropdownOpen(true) reveals the menu items
    expect(toggle).toHaveAttribute('aria-expanded', 'true');
    const accountItem = screen.getByRole('menuitem', { name: 'My Account' });
    expect(accountItem).toBeInTheDocument();
    expect(accountItem).toHaveAttribute('href', '/');
  });

  it('closes the dropdown when the toggle is clicked again', async () => {
    render(<UserDropdowns {...stateDrivenProps} />);

    const toggle = screen.getByRole('button', { name: /G L/ });
    await userEvent.click(toggle);
    expect(screen.getByRole('menuitem', { name: 'My Account' })).toBeInTheDocument();

    await userEvent.click(toggle);
    expect(toggle).toHaveAttribute('aria-expanded', 'false');
    expect(screen.queryByRole('menuitem')).not.toBeInTheDocument();
  });
});
