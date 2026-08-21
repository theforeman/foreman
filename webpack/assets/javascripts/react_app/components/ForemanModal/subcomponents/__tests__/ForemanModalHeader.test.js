import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ForemanModalHeader from '../ForemanModalHeader';
import ModalContext from '../../ForemanModalContext';

const renderWithContext = (ui, contextValue = { title: '' }) =>
  render(
    <ModalContext.Provider value={contextValue}>{ui}</ModalContext.Provider>
  );

describe('ForemanModalHeader', () => {
  it('renders the title from context', () => {
    renderWithContext(<ForemanModalHeader />, { title: 'My Modal Title' });
    expect(screen.getByText('My Modal Title')).toBeInTheDocument();
  });

  it('does not render a title when context title is empty', () => {
    renderWithContext(<ForemanModalHeader />, { title: '' });
    expect(screen.queryByText('My Modal Title')).not.toBeInTheDocument();
  });

  it('renders supplied children', () => {
    renderWithContext(
      <ForemanModalHeader>
        <h1>Custom Header Content</h1>
      </ForemanModalHeader>,
      { title: '' }
    );
    expect(screen.getByText('Custom Header Content')).toBeInTheDocument();
  });

  it('has a close button by default', () => {
    renderWithContext(<ForemanModalHeader />, { title: 'Test' });
    expect(screen.getByRole('button', { name: /close/i })).toBeInTheDocument();
  });

  it('has no close button when closeButton is false', () => {
    renderWithContext(<ForemanModalHeader closeButton={false} />, {
      title: 'Test',
    });
    expect(
      screen.queryByRole('button', { name: /close/i })
    ).not.toBeInTheDocument();
  });
});
