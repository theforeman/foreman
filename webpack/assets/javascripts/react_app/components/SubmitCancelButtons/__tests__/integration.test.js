import React from 'react';
import SubmitCancelButtons, { reducers } from '../index';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

describe('SubmitCancelButtons integration test', () => {
  let component;
  let intgHlpr;
  beforeEach(() => {
    intgHlpr = new IntegrationTestHelper(reducers);
    component = intgHlpr.mount(<SubmitCancelButtons />);
    intgHlpr.takeStoreSnapshot('initial state');
  });

  it('should be in cancel mode when the cancel button is clicked', () => {
    global.location.replace = jest.fn();
    component.find('.btn .btn-default').simulate('click');

    expect(global.location.replace.mock.calls.length).toBe(1);
    intgHlpr.takeStoreSnapshot('cancel mode state');
  });

  it('should be in submit mode when the submit button is clicked', () => {
    component.find('.btn .btn-primary').simulate('click');

    intgHlpr.takeStoreSnapshot('submit mode state');
  });
});
