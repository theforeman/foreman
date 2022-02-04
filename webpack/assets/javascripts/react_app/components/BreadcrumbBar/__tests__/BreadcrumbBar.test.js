import React from 'react';
import { render, fireEvent, screen, act } from '@testing-library/react';
import { mount } from '@theforeman/test';

import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import BreadcrumbBar from '../BreadcrumbBar';
import {
  breadcrumbBar,
  breadcrumbBarSwithcable,
  mockBreadcrumbItemOnClick,
} from '../BreadcrumbBar.fixtures';

const createStubs = () => ({
  openSwitcher: jest.fn(),
  closeSwitcher: jest.fn(),
  loadSwitcherResourcesByResource: jest.fn(),
});

const fixtures = {
  'renders breadcrumb-bar': breadcrumbBar,
  'renders switchable breadcrumb-bar': breadcrumbBarSwithcable,
};

jest.useFakeTimers();

describe('BreadcrumbBar', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(BreadcrumbBar, fixtures));

  describe('triggering', () => {
    it('should trigger callbacks', async () => {
      const props = { ...breadcrumbBarSwithcable, ...createStubs() };
      const { rerender } = render(<BreadcrumbBar {...props} />);

      expect(props.openSwitcher.mock.calls).toHaveLength(0);
      expect(props.closeSwitcher.mock.calls).toHaveLength(0);
      expect(props.loadSwitcherResourcesByResource.mock.calls).toHaveLength(0);

      act(async () =>
        fireEvent.click(screen.getByLabelText('open breadcrumb switcher'))
      );
      expect(props.openSwitcher.mock.calls).toHaveLength(1);
      rerender(<BreadcrumbBar {...{ ...props, isSwitcherOpen: true }} />);
      await act(async () => jest.runAllTimers());
      expect(props.loadSwitcherResourcesByResource.mock.calls).toHaveLength(1);
      rerender(
        <BreadcrumbBar
          {...{ ...props, isSwitcherOpen: true, currentPage: 2, total: 40 }}
        />
      );
      await act(async () =>
        fireEvent.click(screen.getByLabelText('Go to next page'))
      );
      expect(props.loadSwitcherResourcesByResource.mock.calls).toHaveLength(2);

      await act(async () =>
        fireEvent.click(screen.getByLabelText('Go to previous page'))
      );
      expect(props.loadSwitcherResourcesByResource.mock.calls).toHaveLength(3);

      expect(props.loadSwitcherResourcesByResource.mock.calls).toMatchSnapshot(
        'loadSwitcherResourcesByResource calls'
      );
    });

    it('onclick callbacks should work', async () => {
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
      expect(props.onSwitcherItemClick.mock.calls).toHaveLength(0);
      // test breadcrumb switcher item click
      await act(async () =>
        fireEvent.click(screen.getByText('breadcrumb item 3'))
      );
      expect(props.onSwitcherItemClick.mock.calls).toHaveLength(1);

      // test breadcrumb item click
      await act(async () =>
        fireEvent.click(screen.getByText('child with onClick'))
      );
      expect(mockBreadcrumbItemOnClick.mock.calls).toHaveLength(1);
    });
  });
});
