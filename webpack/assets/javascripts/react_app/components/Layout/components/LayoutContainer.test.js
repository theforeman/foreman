import React from 'react';
import { mount, testComponentSnapshotsWithFixtures } from '@theforeman/test';

import LayoutContainer from './LayoutContainer';

const children = [<li key="key">TEST</li>];

const fixtures = {
  'render LayoutContainer': {
    isCollapsed: false,
    children,
  },
};

const removeClass = jest.fn();
const addClass = jest.fn();
global.document.body.classList.remove = removeClass;
global.document.body.classList.add = addClass;

describe('LayoutContainer', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(LayoutContainer, fixtures));

  it('LayoutContainer Collapsed', () => {
    mount(<LayoutContainer isCollapsed>{children}</LayoutContainer>);
    expect(addClass).toBeCalledWith('collapsed-nav');
  });
  it('LayoutContainer Not Collapsed', () => {
    mount(<LayoutContainer isCollapsed={false}>{children}</LayoutContainer>);
    expect(removeClass).toBeCalledWith('collapsed-nav');
  });
});
