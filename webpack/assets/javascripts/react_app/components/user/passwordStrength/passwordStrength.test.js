import { mount } from 'enzyme';
import React from 'react';
import toJson from 'enzyme-to-json';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import PasswordStrength from './';
import {
  initialState,
  passwordMatch,
  passwordNotMatched,
} from './passwordStrength.fixtures';

const mockStore = configureMockStore([thunk]);

function setup(verify, error, state) {
  const store = mockStore(state);

  return mount(<PasswordStrength
      store={store}
      data={{
        className: 'form-control',
        id: 'user_password',
        name: 'user[password]',
        verify,
        error,
        userInputIds: [],
      }}
    />);
}

describe('Verify field', () => {
  it('display verify password field with no error', () => {
    const wrapper = setup(
      { name: 'user[password_confirmation]', error: false },
      false,
      passwordMatch,
    );

    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('display verify password field with error', () => {
    const wrapper = setup(
      { name: 'user[password_confirmation]', error: 'Error' },
      false,
      passwordNotMatched,
    );

    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('verify password field should not rendered', () => {
    const wrapper = setup(false, false, initialState);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
