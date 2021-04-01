import React from 'react';
import { mount } from '@theforeman/test';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import UserDropdowns from './UserDropdowns';
import { userDropdownProps } from '../../Layout.fixtures';

const createStubs = () => ({
  isOpen: true,
});

const fixtures = {
  'render switcher w/loading': {
    ...userDropdownProps,
    ...createStubs(),
  },
};

describe('UserDropdown', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(UserDropdowns, fixtures));

  describe('trigger onClicks', () => {
    const wrapper = mount(
      <UserDropdowns {...userDropdownProps} {...createStubs()} />
    );
    wrapper
      .find('.user_menuitem')
      .last()
      .simulate('click');
  });
});
