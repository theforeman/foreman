import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import Breadcrumb from './Breadcrumb';
import {
  breadcrumbItems,
  breadcrumbTitleItems,
  breadcrumbsWithReplacementTitle,
} from '../BreadcrumbBar.fixtures';

describe('Breadcrumbs', () => {
  it('renders a breadcrumb item per item, linking the ones with a url', () => {
    render(<Breadcrumb {...breadcrumbItems} />);

    expect(screen.getByText('root').closest('a')).toHaveAttribute(
      'href',
      '/some-url'
    );
    expect(screen.getByText('child with onClick')).toBeInTheDocument();
    expect(screen.getByText('active child')).toBeInTheDocument();
  });

  it('renders a single active item', () => {
    render(<Breadcrumb {...breadcrumbTitleItems} />);

    expect(screen.getByText('title')).toBeInTheDocument();
  });

  it('renders the first item as an h1 heading when isTitle is set', () => {
    render(<Breadcrumb {...breadcrumbTitleItems} isTitle />);

    const heading = screen.getByRole('heading', { level: 1 });
    expect(heading).toHaveTextContent('title');
    // the breadcrumb list is not rendered in title mode
    expect(screen.queryByRole('list')).not.toBeInTheDocument();
  });

  it('replaces the active item caption with the title override', () => {
    render(<Breadcrumb {...breadcrumbsWithReplacementTitle} />);

    expect(screen.getByText('root')).toBeInTheDocument();
    expect(screen.getByText('override title')).toBeInTheDocument();
    // the original active caption is replaced
    expect(screen.queryByText('active child')).not.toBeInTheDocument();
  });
});
