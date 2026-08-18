import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import AlertLink from './AlertLink';

describe('AlertLink', () => {
  it('renders a link with href', () => {
    render(<AlertLink href="#">some link</AlertLink>);

    const link = screen.getByRole('link', { name: 'some link' });

    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '#');
  });

  it('calls onClick when the link is clicked', () => {
    const handleClick = jest.fn();

    render(
      <AlertLink href="#" onClick={handleClick}>
        some link
      </AlertLink>
    );

    userEvent.click(screen.getByRole('link', { name: 'some link' }));

    expect(handleClick).toHaveBeenCalled();
  });
});
