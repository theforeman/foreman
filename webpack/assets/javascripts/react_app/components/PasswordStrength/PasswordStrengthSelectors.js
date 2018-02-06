export const doesPasswordsMatch = ({ password, passwordConfirmation }) =>
  !passwordConfirmation || password === passwordConfirmation;
