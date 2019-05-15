import {
  PASSWORD_STRENGTH_PASSWORD_CHANGED,
  PASSWORD_STRENGTH_PASSWORD_CONFIRMATION_CHANGED,
} from './PasswordStrengthConstants';

export const updatePassword = password => ({
  type: PASSWORD_STRENGTH_PASSWORD_CHANGED,
  payload: password,
});

export const updatePasswordConfirmation = password => ({
  type: PASSWORD_STRENGTH_PASSWORD_CONFIRMATION_CHANGED,
  payload: password,
});
