import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
  USERS_PERSONAL_ACCESS_GET_REQUEST,
  USERS_PERSONAL_ACCESS_GET_SUCCESS,
  USERS_PERSONAL_ACCESS_GET_FAILURE

} from '../../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  isOpen: false,
  isSuccessful: false,
  payloadBody: null,
  tokens: []
});

const sortTokens = tokens => {
  return !tokens ? undefined : tokens.sort((a, b) => a.created_at < b.created_at);
};

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON: {
      return state.set('isOpen', false).set('isSuccessful', false).set('payloadBody', null);
    }

    case USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED: {
      return state.set('isOpen', true);
    }

    case USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS: {
      return state.set('isSuccessful', true).set('payloadBody', payload.body).set('tokens', sortTokens([...state.tokens, payload.body]));
    }

    case USERS_PERSONAL_ACCESS_GET_REQUEST:
    case USERS_PERSONAL_ACCESS_GET_SUCCESS: {
      return state.set('tokens', sortTokens(payload.results));
    }

    case USERS_PERSONAL_ACCESS_GET_FAILURE: {
      return state.set(
        payload.id,
        { error: payload.error }
      );
    }

    default: {
      return state;
    }
  }
};
