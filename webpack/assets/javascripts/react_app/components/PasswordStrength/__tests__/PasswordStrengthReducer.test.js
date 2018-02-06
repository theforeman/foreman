import {
  PASSWORD_STRENGTH_PASSWORD_CHANGED,
  PASSWORD_STRENGTH_PASSWROD_CONFIRMATION_CHANGED,
} from '../PasswordStrengthConstants';

import reducer from '../PasswordStrengthReducer';

describe('PasswordStrength reducer', () => {
  const reduce = ({ state, action = {} } = {}) => reducer(state, action);

  it('should return the initial state', () => expect(reduce()).toMatchSnapshot());

  it('should handle PASSWORD_STRENGTH_PASSWORD_CHANGED', () =>
    expect(reduce({
      action: {
        type: PASSWORD_STRENGTH_PASSWORD_CHANGED,
        payload: 'some-password',
      },
    })).toMatchSnapshot());

  it('should handle PASSWORD_STRENGTH_PASSWROD_CONFIRMATION_CHANGED', () =>
    expect(reduce({
      action: {
        type: PASSWORD_STRENGTH_PASSWROD_CONFIRMATION_CHANGED,
        payload: 'some-password',
      },
    })).toMatchSnapshot());
});
