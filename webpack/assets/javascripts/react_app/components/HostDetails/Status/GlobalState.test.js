import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import GlobalState from './GlobalState';
import { STATUS } from '../../../constants';

const renderState = props =>
  render(
    <GlobalState
      responseStatus={STATUS.RESOLVED}
      isOKState={false}
      cannotViewStatuses={false}
      allStatusesCleared={false}
      {...props}
    >
      <span>status table</span>
    </GlobalState>
  );

describe('GlobalState', () => {
  it('shows a success-colored OK state when all statuses are OK', () => {
    const { container } = renderState({ isOKState: true });
    expect(
      screen.getByRole('heading', { name: 'All statuses OK' })
    ).toBeInTheDocument();
    expect(container.querySelector('.pf-v6-c-empty-state')).toHaveClass(
      'pf-m-success'
    );
  });

  it('shows a neutral state when the user cannot view statuses', () => {
    const { container } = renderState({ cannotViewStatuses: true });
    expect(
      screen.getByRole('heading', { name: 'No statuses to show' })
    ).toBeInTheDocument();
    expect(container.querySelector('.pf-v6-c-empty-state')).not.toHaveClass(
      'pf-m-success'
    );
  });

  it('renders the children when statuses are not all OK', () => {
    renderState();
    expect(screen.getByText('status table')).toBeInTheDocument();
  });
});
