import {
  TOASTS_ADD,
  TOASTS_HIDE,
  TOASTS_DELETE
} from '../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  messages: {},
  counter: 0,
  visibilityFilter: 'all'
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case TOASTS_ADD: {
      const id = (state.counter + 1).toString();

      return state.merge({
        messages: state.messages.set(id, Immutable(payload).set('id', id)),
        counter: state.counter + 1
      });
    }

    case TOASTS_HIDE: {
      return state.setIn(['messages', payload.id, 'visible'], false);
    }

    case TOASTS_DELETE: {
      return state.set('messages', state.messages.without(payload.id));
    }

    default: {
      return state;
    }
  }
};
