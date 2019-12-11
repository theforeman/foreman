import React from 'react';
import { mount } from '@theforeman/test';

import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import {
  passwordStrengthDataWithVerify,
  passwordStrengthDataWithInputIds,
  passwordStrengthDefaultProps,
} from '../PasswordStrength.fixtures';

import PasswordStrength from '../PasswordStrength';

const createStubs = () => ({
  updatePassword: jest.fn(),
  updatePasswordConfirmation: jest.fn(),
});

const createProps = (props = {}) => ({
  ...createStubs(),
  ...passwordStrengthDefaultProps,
  ...props,
});

const fixtures = {
  'renders password-strength': createProps(),
  'renders password-strength with password-confirmation': createProps({
    data: { ...passwordStrengthDataWithVerify },
  }),
  'renders password-strength with unmatched password-confirmation': createProps(
    {
      doesPasswordsMatch: false,
      data: { ...passwordStrengthDataWithVerify },
    }
  ),
  'renders password-strength with user-input-ids': createProps({
    data: { ...passwordStrengthDataWithInputIds },
  }),
};

describe('PasswordStrength component', () => {
  jest
    .spyOn(document, 'getElementById')
    .mockImplementation(id => ({ value: id }));

  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(PasswordStrength, fixtures));

  describe('triggering', () => {
    const setInputValue = (input, value) => {
      input.instance().value = value; // eslint-disable-line no-param-reassign
      input.simulate('change', { target: { value } });
    };

    it('should trigger updatePassword', () => {
      const props = createProps();
      const component = mount(<PasswordStrength {...props} />);

      const passwordInput = component.find(`input#${props.data.id}`);
      setInputValue(passwordInput, 'some-value');

      expect(props.updatePassword.mock.calls).toMatchSnapshot();
    });

    it('should trigger updatePasswordConfirmation', () => {
      const props = createProps({
        data: { ...passwordStrengthDataWithVerify },
      });
      const component = mount(<PasswordStrength {...props} />);

      const passwordConfirmationInput = component.find(
        'input#password_confirmation'
      );
      setInputValue(passwordConfirmationInput, 'some-value');

      expect(props.updatePasswordConfirmation.mock.calls).toMatchSnapshot();
    });
  });
});
