jest.unmock('./');

import React from 'react';
import { shallow } from 'enzyme';
import PowerStatus from './';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import { pendingState, errorState, resolvedState } from './PowerStatus.fixtures';
const mockStore = configureMockStore([thunk]);

describe('PowerStatus', () => {

  it('pending', () => {
    const store = mockStore(pendingState);

    const box = shallow(
      <PowerStatus store={ store } data={ {id: 1} }/>
    );

    expect(box.render().find('.spinner.spinner-xs').length).toBe(1);
  });

  it('error', () => {
    const store = mockStore(errorState);

    const box = shallow(
      <PowerStatus store={ store } data={ {id: 1} }/>
    );

    const error = box.render();

    expect(error.find('.fa.fa-power-off.host-power-status.na').length).toBe(1);
    expect(error.find('.fa.fa-power-off.host-power-status.on').length).toBe(0);
    expect(error.find('.fa.fa-power-off.host-power-status.off').length).toBe(0);
  });

  it('resolvedWithOn', () => {
    const store = mockStore(resolvedState);

    const resolvedOnBox = shallow(
      <PowerStatus store={ store } data={ {id: 1} }/>
    );

    const resolvedOnBoxRendered = resolvedOnBox.render();

    expect(resolvedOnBoxRendered.find('.fa.fa-power-off.host-power-status.on').length).toBe(1);
    expect(resolvedOnBoxRendered.find('.fa.fa-power-off.host-power-status.off').length).toBe(0);
    expect(resolvedOnBoxRendered.find('.fa.fa-power-off.host-power-status.na').length).toBe(0);
    expect(resolvedOnBoxRendered.find('[title=On]').length).toBe(1);
  });

  it('resolvedWithOff', () => {
    const store = mockStore(resolvedState);

    const resolvedOnBox = shallow(
      <PowerStatus store={ store } data={ {id: 2} }/>
    );

    const resolvedOffBoxRendered = resolvedOnBox.render();

    expect(resolvedOffBoxRendered.find('.fa.fa-power-off.host-power-status.on').length).toBe(0);
    expect(resolvedOffBoxRendered.find('.fa.fa-power-off.host-power-status.off').length).toBe(1);
    expect(resolvedOffBoxRendered.find('.fa.fa-power-off.host-power-status.na').length).toBe(0);
    expect(resolvedOffBoxRendered.find('[title=Off]').length).toBe(1);
  });
});
