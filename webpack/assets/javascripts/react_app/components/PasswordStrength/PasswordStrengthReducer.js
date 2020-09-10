import Immutable from 'seamless-immutable';

import {
  PASSWORD_STRENGTH_PASSWORD_CHANGED,
  PASSWORD_STRENGTH_PASSWORD_CONFIRMATION_CHANGED,
} from './PasswordStrengthConstants';

const initialState = Immutable({
  password: '',
  passwordConfirmation: '',
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case PASSWORD_STRENGTH_PASSWORD_CHANGED:
      return state.set('password', payload);

    case PASSWORD_STRENGTH_PASSWORD_CONFIRMATION_CHANGED:
      return state.set('passwordConfirmation', payload);

    default:
      return state;
  }
};
