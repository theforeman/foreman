import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import Breadcrumb from './Breadcrumb';
import {
  breadcrumbItems,
  breadcrumbTitleItems,
  breadcrumbsWithReplacementTitle,
  mockBreadcrumbItemOnClick,
} from '../BreadcrumbBar.fixtures';

describe('Breadcrumb', () => {
  it('renders breadcrumb items', () => {
    render(<Breadcrumb {...breadcrumbItems} />);

    expect(screen.getByText('root')).toBeInTheDocument();
    expect(screen.getByText('child with onClick')).toBeInTheDocument();
    expect(screen.getByText('active child')).toBeInTheDocument();
  });

  it('renders the first item as a link', () => {
    render(<Breadcrumb {...breadcrumbItems} />);

    const link = screen.getByRole('link', { name: 'root' });
    expect(link).toHaveAttribute('href', '/some-url');
  });

  it('renders h1 title when isTitle is true', () => {
    render(<Breadcrumb {...breadcrumbTitleItems} isTitle />);

    expect(
      screen.getByRole('heading', { name: 'title', level: 1 })
    ).toBeInTheDocument();
  });

  it('renders title override for the active item', () => {
    render(<Breadcrumb {...breadcrumbsWithReplacementTitle} />);

    expect(screen.getByText('override title')).toBeInTheDocument();
    expect(screen.queryByText('active child')).not.toBeInTheDocument();
  });

  it('renders children inside the active breadcrumb item', () => {
    render(
      <Breadcrumb {...breadcrumbItems}>
        <span>child content</span>
      </Breadcrumb>
    );

    expect(screen.getByText('child content')).toBeInTheDocument();
  });

  it('calls onClick handler when a breadcrumb item with onClick is clicked', async () => {
    mockBreadcrumbItemOnClick.mockClear();
    render(<Breadcrumb {...breadcrumbItems} />);

    await userEvent.click(screen.getByText('child with onClick'));

    expect(mockBreadcrumbItemOnClick).toHaveBeenCalledTimes(1);
  });

  it('does not call onClick for items without an onClick handler', async () => {
    const onClick = jest.fn();
    const items = {
      items: [
        { caption: 'no handler' },
        { caption: 'with handler', onClick },
        { caption: 'active' },
      ],
    };
    render(<Breadcrumb {...items} />);

    await userEvent.click(screen.getByText('no handler'));

    expect(onClick).not.toHaveBeenCalled();
  });

  it('renders an icon when caption has icon data', () => {
    const itemsWithIcon = {
      items: [
        {
          caption: {
            icon: { url: '/icon.png', alt: 'test icon' },
            text: 'icon item',
          },
        },
      ],
    };
    render(<Breadcrumb {...itemsWithIcon} />);

    const icon = screen.getByRole('img', { name: 'test icon' });
    expect(icon).toHaveAttribute('src', '/icon.png');
    expect(screen.getByText('icon item')).toBeInTheDocument();
  });
});
