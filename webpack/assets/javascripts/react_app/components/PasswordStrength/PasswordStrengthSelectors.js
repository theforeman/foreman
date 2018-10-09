export const doesPasswordsMatch = ({ password, passwordConfirmation }) =>
  !passwordConfirmation || password === passwordConfirmation;

export const passwordPresent = passwordStrength =>
  passwordStrength && !!passwordStrength.password;
