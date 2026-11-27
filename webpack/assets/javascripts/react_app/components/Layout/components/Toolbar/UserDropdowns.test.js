import React from 'react';
import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { flushPatternflyTimers } from '../../../../common/rtlTestHelpers';

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
    await act(async () => {
      userEvent.click(toggle);
    });
    await flushPatternflyTimers();

    // setUserDropdownOpen(true) reveals the menu items
    expect(toggle).toHaveAttribute('aria-expanded', 'true');
    const accountItem = screen.getByRole('menuitem', { name: 'My Account' });
    expect(accountItem).toBeInTheDocument();
    expect(accountItem).toHaveAttribute('href', '/');
  });

  it('closes the dropdown when the toggle is clicked again', async () => {
    render(<UserDropdowns {...stateDrivenProps} />);

    const toggle = screen.getByRole('button', { name: /G L/ });
    await act(async () => {
      userEvent.click(toggle);
    });
    await flushPatternflyTimers();
    expect(screen.getByRole('menuitem', { name: 'My Account' })).toBeInTheDocument();

    await act(async () => {
      userEvent.click(toggle);
    });
    await flushPatternflyTimers();
    expect(toggle).toHaveAttribute('aria-expanded', 'false');
    await waitFor(() =>
      expect(screen.queryByRole('menuitem')).not.toBeInTheDocument()
    );
  });

  it('passes html_options to the link so rails-ujs can use data-method', async () => {
    const user = {
      ...stateDrivenProps.user,
      user_dropdown: [
        {
          ...stateDrivenProps.user.user_dropdown[0],
          children: [
            { type: 'item', url: '/users/1/edit', name: 'My Account' },
            { type: 'divider' },
            {
              type: 'item',
              url: '/users/logout',
              name: 'Log Out',
              html_options: { 'data-method': 'post' },
            },
          ],
        },
      ],
    };
    render(<UserDropdowns {...stateDrivenProps} user={user} />);
    await act(async () => {
      userEvent.click(screen.getByRole('button', { name: /G L/ }));
    });
    await flushPatternflyTimers();

    const logout = screen.getByRole('menuitem', { name: 'Log Out' });
    expect(logout.tagName).toBe('A');
    expect(logout).toHaveAttribute('href', '/users/logout');
    expect(logout).toHaveAttribute('data-method', 'post');
    expect(logout).toHaveClass('user_menuitem');
    expect(screen.getByRole('separator')).toBeInTheDocument();
  });

  it('closes the dropdown after an item is chosen', async () => {
    render(<UserDropdowns {...stateDrivenProps} />);
    const toggle = screen.getByRole('button', { name: /G L/ });
    await act(async () => {
      userEvent.click(toggle);
    });
    await flushPatternflyTimers();

    await act(async () => {
      userEvent.click(screen.getByRole('menuitem', { name: 'My Account' }));
    });
    await flushPatternflyTimers();

    expect(toggle).toHaveAttribute('aria-expanded', 'false');
  });
});
