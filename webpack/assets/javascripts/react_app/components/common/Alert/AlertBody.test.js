import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import AlertBody from './AlertBody';

describe('AlertBody', () => {
  it('should render with title and message', () => {
    render(<AlertBody title="some title" message="some message" />);

    expect(screen.getByText('some title')).toBeInTheDocument();
    expect(screen.getByText('some message')).toBeInTheDocument();
  });

  it('should render with children', () => {
    render(
      <AlertBody>
        <span>a Child</span>
      </AlertBody>
    );

    expect(screen.getByText('a Child')).toBeInTheDocument();
  });

  it('should render with link', () => {
    render(<AlertBody link={{ children: 'link text', href: '#' }} />);

    const link = screen.getByRole('link', { name: 'link text' });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '#');
  });

  it('should render with all props', () => {
    render(
      <AlertBody
        title="some title"
        message="some message"
        link={{ children: 'link text', href: '#' }}
      >
        <span>a Child</span>
      </AlertBody>
    );

    expect(screen.getByText('some title')).toBeInTheDocument();
    expect(screen.getByText('some message')).toBeInTheDocument();
    expect(screen.getByText('a Child')).toBeInTheDocument();
    expect(
      screen.getByRole('link', { name: 'link text' })
    ).toBeInTheDocument();
  });
});
