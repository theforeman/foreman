import React from 'react';
import { render, screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import BreadcrumbBar from '../BreadcrumbBar';
import {
  breadcrumbBar,
  breadcrumbBarSwithcable,
  mockBreadcrumbItemOnClick,
  resource,
} from '../BreadcrumbBar.fixtures';

const createStubs = () => ({
  openSwitcher: jest.fn(),
  closeSwitcher: jest.fn(),
  loadSwitcherResourcesByResource: jest.fn(),
});

describe('BreadcrumbBar', () => {
  afterEach(() => jest.clearAllMocks());

  describe('rendering', () => {
    it('renders non-switchable breadcrumb bar', () => {
      render(<BreadcrumbBar {...breadcrumbBar} />);

      expect(screen.getByText('root')).toBeInTheDocument();
      expect(screen.getByText('child with onClick')).toBeInTheDocument();
      expect(screen.getByText('active child')).toBeInTheDocument();
      expect(
        screen.queryByRole('button', { name: 'open breadcrumb switcher' })
      ).not.toBeInTheDocument();
    });

    it('renders switchable breadcrumb bar with switcher button', () => {
      render(<BreadcrumbBar {...breadcrumbBarSwithcable} />);

      expect(screen.getByText('root')).toBeInTheDocument();
      expect(screen.getByText('child with onClick')).toBeInTheDocument();
      expect(screen.getByText('active child')).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'open breadcrumb switcher' })
      ).toBeInTheDocument();
    });
  });

  describe('triggering', () => {
    beforeEach(() => jest.useFakeTimers());
    afterEach(() => jest.useRealTimers());

    it('should trigger callbacks on switcher interaction', async () => {
      const props = { ...breadcrumbBarSwithcable, ...createStubs() };
      const { rerender } = render(<BreadcrumbBar {...props} />);

      expect(props.openSwitcher).not.toHaveBeenCalled();
      expect(props.closeSwitcher).not.toHaveBeenCalled();
      expect(props.loadSwitcherResourcesByResource).not.toHaveBeenCalled();

      userEvent.click(
        screen.getByRole('button', { name: 'open breadcrumb switcher' })
      );
      expect(props.openSwitcher).toHaveBeenCalledTimes(1);

      rerender(<BreadcrumbBar {...{ ...props, isSwitcherOpen: true }} />);
      await act(async () => jest.runAllTimers());
      expect(props.loadSwitcherResourcesByResource).toHaveBeenCalledTimes(1);
      expect(props.loadSwitcherResourcesByResource).toHaveBeenCalledWith(
        resource
      );

      rerender(
        <BreadcrumbBar
          {...{ ...props, isSwitcherOpen: true, currentPage: 2, total: 40 }}
        />
      );

      userEvent.click(
        screen.getByRole('button', { name: 'Go to next page' })
      );
      expect(props.loadSwitcherResourcesByResource).toHaveBeenCalledTimes(2);
      expect(props.loadSwitcherResourcesByResource).toHaveBeenLastCalledWith(
        resource,
        { page: 3, searchQuery: 'some value', perPage: 10 }
      );

      userEvent.click(
        screen.getByRole('button', { name: 'Go to previous page' })
      );
      expect(props.loadSwitcherResourcesByResource).toHaveBeenCalledTimes(3);
      expect(props.loadSwitcherResourcesByResource).toHaveBeenLastCalledWith(
        resource,
        { page: 2, searchQuery: 'some value', perPage: 10 }
      );
    });

    it('should call onClick callbacks', async () => {
      window.history.pushState({}, 'Test Title', '/hosts/1');
      const props = {
        ...breadcrumbBarSwithcable,
        ...createStubs(),
        onSwitcherItemClick: jest.fn(),
        resourceSwitcherItems: [{ name: 'breadcrumb item 3', id: '1' }],
        isSwitcherOpen: true,
      };

      render(<BreadcrumbBar {...props} />);
      await act(async () => jest.runAllTimers());

      expect(props.onSwitcherItemClick).not.toHaveBeenCalled();

      userEvent.click(screen.getByText('breadcrumb item 3'));
      await act(async () => jest.runAllTimers());
      expect(props.onSwitcherItemClick).toHaveBeenCalledTimes(1);

      userEvent.click(screen.getByText('child with onClick'));
      await act(async () => jest.runAllTimers());
      expect(mockBreadcrumbItemOnClick).toHaveBeenCalledTimes(1);
    });
  });
});
