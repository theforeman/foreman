import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import {
  pendingState,
  errorState,
  resolvedState,
} from './PowerStatus.fixtures';
import PowerStatus from './';

jest.unmock('./');

const mockStore = configureMockStore([thunk]);

describe('PowerStatus', () => {
  it('pending', () => {
    const store = mockStore(pendingState);

    const box = shallow(<PowerStatus store={store} data={{ id: 1 }} />);

    expect(box.render().find('.spinner.spinner-xs')).toHaveLength(1);
  });

  it('error', () => {
    const store = mockStore(errorState);

    const box = shallow(<PowerStatus store={store} data={{ id: 1 }} />);

    const error = box.render();

    expect(toJson(error)).toMatchSnapshot();
  });

  it('resolvedWithOn', () => {
    const store = mockStore(resolvedState);

    const resolvedOnBox = shallow(
      <PowerStatus store={store} data={{ id: 1 }} />
    );

    const resolvedOnBoxRendered = resolvedOnBox.render();

    expect(toJson(resolvedOnBoxRendered)).toMatchSnapshot();
  });

  it('resolvedWithOff', () => {
    const store = mockStore(resolvedState);

    const resolvedOnBox = shallow(
      <PowerStatus store={store} data={{ id: 2 }} />
    );

    const resolvedOffBoxRendered = resolvedOnBox.render();

    expect(toJson(resolvedOffBoxRendered)).toMatchSnapshot();
  });
});
