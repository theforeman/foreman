import React from 'react';
import { mount } from 'enzyme';

import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import Layout from '../Layout';
import { layoutMock, noItemsMock, hasTaxonomiesMock } from '../Layout.fixtures';

jest.mock('../../notifications', () => 'span');

const didMountStubs = () => ({
  fetchMenuItems: jest.fn(),
  changeLocation: jest.fn(),
  changeOrganization: jest.fn(),
});

const fixtures = {
  'renders layout': layoutMock,
};

describe('Layout', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(Layout, fixtures));

  describe('triggering', () => {
    it('should trigger fetchMenuItems, items array is empty', () => {
      const props = { ...noItemsMock, ...didMountStubs() };
      mount(<Layout {...props} />);

      expect(props.fetchMenuItems.mock.calls).toHaveLength(1);
      expect(props.changeLocation.mock.calls).toHaveLength(1);
      expect(props.changeOrganization.mock.calls).toHaveLength(1);
    });
    it('should not trigger fetchMenuItems, changeLocation, ChangeOrganization', () => {
      const props = { ...hasTaxonomiesMock, ...didMountStubs() };
      mount(<Layout {...props} />);

      expect(props.fetchMenuItems.mock.calls).toHaveLength(0);
      expect(props.changeLocation.mock.calls).toHaveLength(0);
      expect(props.changeOrganization.mock.calls).toHaveLength(0);
    });
  });
});
