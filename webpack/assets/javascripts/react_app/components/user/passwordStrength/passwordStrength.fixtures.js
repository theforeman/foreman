import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  passwordStrength: {
    password: {
      value: '',
      match: true,
    },
  },
});

export const passwordMatch = Immutable({
  passwordStrength: {
    password: {
      value: 'password',
      match: true,
    },
  },
});

export const passwordNotMatched = Immutable({
  passwordStrength: {
    password: {
      value: 'password',
      match: false,
    },
  },
});
