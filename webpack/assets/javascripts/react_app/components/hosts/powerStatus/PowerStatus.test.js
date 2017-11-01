// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

jest.unmock('./');

import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import PowerStatus from './';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import {
  pendingState,
  errorState,
  resolvedState,
} from './PowerStatus.fixtures';
const mockStore = configureMockStore([thunk]);

describe('PowerStatus', () => {
  it('pending', () => {
    const store = mockStore(pendingState);

    const box = shallow(<PowerStatus store={store} data={{ id: 1 }} />);

    expect(box.render().find('.spinner.spinner-xs').length).toBe(1);
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
