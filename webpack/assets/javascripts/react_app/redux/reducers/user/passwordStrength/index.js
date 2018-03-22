import Immutable from 'seamless-immutable';
import {
  PASSWORD_STRENGTH_PASSWROD_CHANGED,
  PASSWORD_STRENGTH_PASSWROD_MATCHED,
} from '../../../consts';

const initialState = Immutable({
  password: {
    value: '',
    match: true,
  },
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case PASSWORD_STRENGTH_PASSWROD_CHANGED: {
      return state.setIn(['password', 'value'], payload);
    }
    case PASSWORD_STRENGTH_PASSWROD_MATCHED: {
      return state.setIn(['password', 'match'], payload);
    }

    default: {
      return state;
    }
  }
};
