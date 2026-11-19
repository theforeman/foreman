import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import Link from './index';

describe('documentation links', () => {
  it('should have an external link to documentation', () => {
    render(<Link href="http://theforeman.org" />);

    expect(
      screen.getByRole('menuitem', { name: /Documentation/i })
    ).toBeInTheDocument();
  });

  it('opens the documentation in a new window on click', () => {
    const open = jest.spyOn(window, 'open').mockImplementation(() => ({}));
    render(<Link href="http://theforeman.org" />);

    fireEvent.click(screen.getByRole('menuitem', { name: /Documentation/i }));

    expect(open).toHaveBeenCalledWith('http://theforeman.org', '_blank');
    open.mockRestore();
  });

  it('renders custom children as the label', () => {
    render(<Link href="http://theforeman.org">Read the docs</Link>);

    expect(
      screen.getByRole('menuitem', { name: /Read the docs/i })
    ).toBeInTheDocument();
  });
});
