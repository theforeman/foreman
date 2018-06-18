import React from 'react';
import { mount } from 'enzyme';

import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import BreadcrumbBar from '../BreadcrumbBar';
import {
  breadcrumbBar,
  breadcrumbBarSwithcable,
  mockBreadcrumbItemOnClick,
} from '../BreadcrumbBar.fixtures';

const createStubs = () => ({
  toggleSwitcher: jest.fn(),
  closeSwitcher: jest.fn(),
  loadSwitcherResourcesByResource: jest.fn(),
});

const fixtures = {
  'renders breadcrumb-bar': breadcrumbBar,
  'renders switchable breadcrumb-bar': breadcrumbBarSwithcable,
};

describe('BreadcrumbBar', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(BreadcrumbBar, fixtures));

  describe('triggering', () => {
    it('should trigger callbacks', () => {
      const props = { ...breadcrumbBarSwithcable, ...createStubs() };
      const component = mount(<BreadcrumbBar {...props} />);

      expect(props.toggleSwitcher.mock.calls.length).toBe(0);
      expect(props.closeSwitcher.mock.calls.length).toBe(0);
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(0);

      const toggleSwitcherClick = () => component.find('.breadcrumb-switcher .btn').simulate('click');
      const openSwitcher = () => component.setProps({ isSwitcherOpen: true });

      toggleSwitcherClick();
      expect(props.toggleSwitcher.mock.calls.length).toBe(1);

      openSwitcher();
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(1);

      component.setProps({ currentPage: 2, totalPages: 3 });

      component.find('.breadcrumb-switcher .next a').simulate('click');
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(2);

      component.find('.breadcrumb-switcher .previous a').simulate('click');
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(3);

      expect(props.loadSwitcherResourcesByResource.mock.calls).toMatchSnapshot('loadSwitcherResourcesByResource calls');
    });

    it('onclick callbacks should work', () => {
      const props = {
        ...breadcrumbBarSwithcable,
        ...createStubs(),
        onSwitcherItemClick: jest.fn(),
        resourceSwitcherItems: [{ name: 'a', id: '1' }],
      };
      const component = mount(<BreadcrumbBar {...props} />);

      // test breadcrumb switcher item click
      expect(props.onSwitcherItemClick.mock.calls.length).toBe(0);
      component.setProps({ isSwitcherOpen: true });
      component.update();
      component.find('.scrollable-list.list-group button').simulate('click');
      expect(props.onSwitcherItemClick.mock.calls.length).toBe(1);

      // test breadcrumb item click
      component.find('.breadcrumbs-pf-title.breadcrumb a').at(1).simulate('click');
      expect(mockBreadcrumbItemOnClick.mock.calls.length).toBe(1);
    });
  });
});
