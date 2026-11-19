import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { createMenuLinkComponent } from './index';

describe('createMenuLinkComponent', () => {
  it('renders an anchor with href, attributes and merged class names', () => {
    const MenuLink = createMenuLinkComponent(
      '/users/logout',
      { 'data-method': 'post' },
      'user_menuitem'
    );
    render(<MenuLink className="pf-v6-c-menu__item">Log Out</MenuLink>);
    const link = screen.getByRole('link', { name: 'Log Out' });
    expect(link).toHaveAttribute('href', '/users/logout');
    expect(link).toHaveAttribute('data-method', 'post');
    expect(link).toHaveClass('pf-v6-c-menu__item');
    expect(link).toHaveClass('user_menuitem');
  });

  it('returns the same component for the same arguments so items do not remount', () => {
    const first = createMenuLinkComponent('/a', { 'data-method': 'post' });
    const second = createMenuLinkComponent('/a', { 'data-method': 'post' });
    const other = createMenuLinkComponent('/b', { 'data-method': 'post' });
    expect(second).toBe(first);
    expect(other).not.toBe(first);
  });
});
