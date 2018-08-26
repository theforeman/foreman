import React from 'react';
import { shallow } from 'enzyme';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import UserDropdowns from '../components/UserDropdowns';
import { userDropdownProps } from '../Layout.fixtures';

const createStubs = () => ({
  changeActiveMenu: jest.fn(),
});

const fixtures = {
  'render switcher w/loading': { ...userDropdownProps, ...createStubs() },
};

describe('UserDropdown', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(UserDropdowns, fixtures));

  describe('trigger onClicks', () => {
    const wrapper = shallow(<UserDropdowns { ...userDropdownProps } { ...createStubs() } />);

    wrapper.find('.user_menuitem').simulate('click');
  });
});
