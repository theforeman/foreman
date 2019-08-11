import Immutable from 'seamless-immutable';
import { TOASTS_ADD, TOASTS_DELETE, TOASTS_CLEAR } from '../../consts';

const initialState = Immutable({
  messages: {},
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case TOASTS_ADD: {
      return state.setIn(['messages', payload.key], payload.message);
    }

    case TOASTS_DELETE: {
      return state.set('messages', state.messages.without(payload.key));
    }

    case TOASTS_CLEAR: {
      return state.set('messages', {});
    }

    default: {
      return state;
    }
  }
};
