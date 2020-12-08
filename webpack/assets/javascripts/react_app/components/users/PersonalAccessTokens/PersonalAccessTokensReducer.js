import Immutable from 'seamless-immutable';
import {
  PERSONAL_ACCESS_TOKENS_REQUEST,
  PERSONAL_ACCESS_TOKENS_SUCCESS,
  PERSONAL_ACCESS_TOKENS_FAILURE,
  PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED,
  PERSONAL_ACCESS_TOKEN_CLEAR,
} from './PersonalAccessTokensConstants';

const initialState = Immutable({ tokens: [] });

export default (state = initialState, { type, payload }) => {
  switch (type) {
    case PERSONAL_ACCESS_TOKENS_REQUEST:
    case PERSONAL_ACCESS_TOKENS_SUCCESS:
      return state.set('tokens', payload.results || []);
    case PERSONAL_ACCESS_TOKENS_FAILURE:
      return state.set(payload.id, { error: payload.error });
    case PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED: {
      const { token_value: newPersonalAccessToken, ...token } = payload.data;

      return state
        .set('newPersonalAccessToken', newPersonalAccessToken)
        .set('tokens', [...state.tokens, token]);
    }
    case PERSONAL_ACCESS_TOKEN_CLEAR:
      return state.set('newPersonalAccessToken', null);
    default: {
      return state;
    }
  }
};
