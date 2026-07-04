import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import SkeletonLoader from '.';
import { STATUS } from '../../../constants';

describe('SkeletonLoader', () => {
  it('renders a skeleton while loading', () => {
    const { container } = render(
      <SkeletonLoader status={STATUS.PENDING} skeletonProps={{ count: 3 }} />
    );

    // react-loading-skeleton renders skeleton spans
    expect(
      container.querySelectorAll('.react-loading-skeleton')
    ).toHaveLength(3);
  });

  it('renders the empty state when resolved with no children', () => {
    render(
      <SkeletonLoader status={STATUS.RESOLVED} emptyState="custom empty" />
    );

    expect(screen.getByText('custom empty')).toBeInTheDocument();
  });

  it('renders children when resolved', () => {
    render(
      <SkeletonLoader status={STATUS.RESOLVED} emptyState="custom empty">
        <div>a child</div>
      </SkeletonLoader>
    );

    expect(screen.getByText('a child')).toBeInTheDocument();
    expect(screen.queryByText('custom empty')).not.toBeInTheDocument();
  });

  it('renders the custom error node on error', () => {
    render(
      <SkeletonLoader status={STATUS.ERROR} errorNode="custom error node" />
    );

    expect(screen.getByText('custom error node')).toBeInTheDocument();
  });
});
