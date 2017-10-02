import {
  PASSWORD_STRENGTH_PASSWROD_CHANGED,
  PASSWORD_STRENGTH_PASSWROD_MATCHED,
} from '../../../consts';

export const updatePassword = newPass => ({
  type: PASSWORD_STRENGTH_PASSWROD_CHANGED,
  payload: newPass,
});

export const checkPasswordsMatch = (password, retypedPassword) => {
  const matched = password === retypedPassword;

  return {
    type: PASSWORD_STRENGTH_PASSWROD_MATCHED,
    payload: matched,
  };
};
