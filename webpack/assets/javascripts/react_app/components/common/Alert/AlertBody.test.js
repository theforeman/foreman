import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import AlertBody from './AlertBody';

describe('AlertBody', () => {
  it('should render with title and message', () => {
    render(<AlertBody title="some title" message="some message" />);

    // Should display both title and message
    expect(screen.getByText('some title')).toBeInTheDocument();
    expect(screen.getByText('some message')).toBeInTheDocument();
  });

  it('should render with children content', () => {
    render(
      <AlertBody>
        <span>a Child</span>
      </AlertBody>
    );

    // Should display children content
    expect(screen.getByText('a Child')).toBeInTheDocument();
  });

  it('should render with link', () => {
    render(<AlertBody link={{ children: 'link text', href: '#' }} />);

    // Should display link with correct attributes
    const link = screen.getByRole('link', { name: 'link text' });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '#');
  });

  it('should render with all props combined', () => {
    render(
      <AlertBody
        title="some title"
        message="some message"
        link={{ children: 'link text', href: '#' }}
      >
        <span>a Child</span>
      </AlertBody>
    );

    // Should display title
    expect(screen.getByText('some title')).toBeInTheDocument();

    // Should display message
    expect(screen.getByText('some message')).toBeInTheDocument();

    // Should display link
    const link = screen.getByRole('link', { name: 'link text' });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '#');

    // Should display children
    expect(screen.getByText('a Child')).toBeInTheDocument();
  });

  it('should render with only title', () => {
    render(<AlertBody title="only title" />);

    expect(screen.getByText('only title')).toBeInTheDocument();
    expect(screen.queryByText('some message')).not.toBeInTheDocument();
  });

  it('should render with only message', () => {
    render(<AlertBody message="only message" />);

    expect(screen.getByText('only message')).toBeInTheDocument();
  });

  it('should render empty AlertBody gracefully', () => {
    render(<AlertBody />);

    // Should render without crashing even with no props
    expect(screen.container.firstChild).toBeInTheDocument();
  });

  it('should handle complex link objects', () => {
    const linkProps = {
      children: 'Complex Link',
      href: 'https://example.com',
      target: '_blank',
      rel: 'noopener noreferrer'
    };

    render(<AlertBody link={linkProps} />);

    const link = screen.getByRole('link', { name: 'Complex Link' });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', 'https://example.com');
    expect(link).toHaveAttribute('target', '_blank');
    expect(link).toHaveAttribute('rel', 'noopener noreferrer');
  });

  it('should render multiple children', () => {
    render(
      <AlertBody title="Title">
        <div>First child</div>
        <div>Second child</div>
        <span>Third child</span>
      </AlertBody>
    );

    expect(screen.getByText('Title')).toBeInTheDocument();
    expect(screen.getByText('First child')).toBeInTheDocument();
    expect(screen.getByText('Second child')).toBeInTheDocument();
    expect(screen.getByText('Third child')).toBeInTheDocument();
  });

  it('should be accessible', () => {
    render(
      <AlertBody
        title="Accessible Title"
        message="Accessible message"
        link={{ children: 'Accessible link', href: '#test' }}
      >
        <span>Accessible child</span>
      </AlertBody>
    );

    // All content should be accessible
    expect(screen.getByText('Accessible Title')).toBeInTheDocument();
    expect(screen.getByText('Accessible message')).toBeInTheDocument();
    expect(screen.getByText('Accessible child')).toBeInTheDocument();

    const link = screen.getByRole('link', { name: 'Accessible link' });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '#test');
  });
});
