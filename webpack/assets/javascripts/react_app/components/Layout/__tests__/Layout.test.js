import React from 'react';
import { mount } from '@theforeman/test';

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
      const spy = jest.spyOn(console, 'error').mockImplementation();

      mount(<Layout {...props} />);

      // Currently expect a prop warning since VerticalNav passes an object into NavExpandable title prop although it expects a string. This will change soon.
      expect(spy).toHaveBeenCalledTimes(1);
      // eslint-disable-next-line
      expect(console.error.mock.calls[0][0]).toEqual(expect.stringContaining('Warning: Failed prop type: Invalid prop `title` of type `object` supplied to `NavExpandable`, expected `string`'));
      spy.mockRestore();

      expect(props.fetchMenuItems.mock.calls).toHaveLength(0);
      expect(props.changeLocation.mock.calls).toHaveLength(0);
      expect(props.changeOrganization.mock.calls).toHaveLength(0);
    });
  });
});
