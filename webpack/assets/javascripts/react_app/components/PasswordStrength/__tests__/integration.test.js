import React from 'react';

import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import { passwords } from '../PasswordStrength.fixtures';
import PasswordStrength, { reducers } from '../index';

// mock the document.getElementById
document.getElementById = jest.fn(id => ({ value: passwords[id].password }));

describe('PasswordStrength integration test', () => {
  // the password-strength 3rd-party reading the input.value instead the event.value
  // therefore, it is not enough to simulate a change-event
  const setInputValue = (input, value) => {
    input.instance().value = value; // eslint-disable-line no-param-reassign
    input.simulate('change', { target: { value } });
  };

  it('should flow', () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);

    const component = integrationTestHelper.mount(
      <div>
        <input id="username" value={passwords.username.password} readOnly />
        <input id="email" value={passwords.email.password} readOnly />
        <PasswordStrength
          data={{
            className: 'form-control',
            id: 'user_password',
            name: 'user[password]',
            verify: { name: 'user[password_confirmation]' },
            userInputIds: ['username', 'email'],
          }}
        />
      </div>
    );

    const passwordInput = component.find('input#user_password');
    const passwordConfirmationInput = component.find(
      'input#password_confirmation'
    );
    const passwordWarning = component.find(
      '.ReactPasswordStrength-strength-desc'
    );

    integrationTestHelper.takeStoreSnapshot('initial state');

    Object.keys(passwords).forEach(key => {
      const { password, expected } = passwords[key];

      setInputValue(passwordInput, password);

      expect(passwordWarning.text()).toBe(expected);
      integrationTestHelper.takeStoreAndLastActionSnapshot(`${key} fixture`);
    });

    setInputValue(passwordConfirmationInput, passwords.strong.password);
    expect(
      component.find(`CommonForm[label="${'Verify'}"] .help-block`)
    ).toHaveLength(1);
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'unmached password confirmation'
    );

    setInputValue(passwordConfirmationInput, passwords.veryStrong.password);
    expect(
      component.find(`CommonForm[label="${'Verify'}"] .help-block`)
    ).toHaveLength(0);
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'mached password confirmation'
    );
  });
});
