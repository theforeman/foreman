import { STATUS } from '../../../constants';
import { selectAPIStatus } from '../../../redux/API/APISelectors';
import { PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED } from './PersonalAccessTokensConstants';

export const selectNewPersonalAccessToken = state =>
  state.personalAccessTokens.newPersonalAccessToken;

export const selectTokens = state => state.personalAccessTokens.tokens;

export const selectIsSubmitting = state =>
  selectAPIStatus(state, PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED) ===
  STATUS.PENDING;
