import React from 'react';
import { mount } from 'enzyme';
import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import { diffMock } from './DiffView.fixtures';

import DiffContainer from './DiffContainer';

const fixtures = {
  'render DiffContainer': diffMock,
};

describe('DiffContainer', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(DiffContainer, fixtures));

  describe('simulate onClick', () => {
    const wrapper = mount(<DiffContainer {...diffMock} />);
    wrapper
      .find('#split-btn')
      .at(0)
      .simulate('click');
    expect(wrapper.state().viewType).toBe('split');
    wrapper
      .find('#unified-btn')
      .at(0)
      .simulate('click');
    expect(wrapper.state().viewType).toBe('unified');
  });
});
