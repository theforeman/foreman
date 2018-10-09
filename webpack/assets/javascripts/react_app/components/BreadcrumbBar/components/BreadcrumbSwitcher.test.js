import React from 'react';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';

import BreadcrumbSwitcher from './BreadcrumbSwitcher';
import {
  breadcrumbSwitcherLoading,
  breadcrumbSwitcherLoaded,
  breadcrumbSwitcherLoadedWithPagination,
} from '../BreadcrumbBar.fixtures';

const createStubs = () => ({
  onOpen: jest.fn(),
  onHide: jest.fn(),
  onTogglerClick: jest.fn(),
  onPrevPageClick: jest.fn(),
  onNextPageClick: jest.fn(),
});

const fixtures = {
  'render closed': { open: false, ...createStubs() },
  'render loading state': {
    open: true,
    ...breadcrumbSwitcherLoading,
    ...createStubs(),
  },
  'render resources list': {
    open: true,
    ...breadcrumbSwitcherLoaded,
    ...createStubs(),
  },
  'render resources list with pagination': {
    open: true,
    ...breadcrumbSwitcherLoadedWithPagination,
    ...createStubs(),
  },
};

describe('BreadcrumbSwitcher', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(
      BreadcrumbSwitcher,
      fixtures
    );

    const filterSnapshotGarbage = componentJson => {
      const componentOverlay = componentJson.children.filter(
        ({ type }) => type === 'Overlay'
      )[0];
      delete componentOverlay.props.container;
      return componentJson;
    };

    const testBreadcrumbSwitcherSnapshot = (description, component) =>
      it(description, () =>
        expect(filterSnapshotGarbage(toJson(component))).toMatchSnapshot()
      );

    components.forEach(({ description, component }) =>
      testBreadcrumbSwitcherSnapshot(description, component)
    );
  });

  describe('triggering', () => {
    it('should correctly trigger onOpen', () => {
      let openCounter = 0;
      const onOpen = jest.fn();
      const component = mount(
        <BreadcrumbSwitcher open={false} onOpen={onOpen} />
      );

      const expectOpOpenCallsToMatchCounter = () =>
        expect(onOpen.mock.calls).toHaveLength(openCounter);

      const open = () => {
        openCounter += 1;
        component.setProps({ open: true });
      };
      const close = () => component.setProps({ open: false });

      expectOpOpenCallsToMatchCounter();
      open();
      expectOpOpenCallsToMatchCounter();
      close();
      expectOpOpenCallsToMatchCounter();
      open();
      expectOpOpenCallsToMatchCounter();
    });
  });
});
