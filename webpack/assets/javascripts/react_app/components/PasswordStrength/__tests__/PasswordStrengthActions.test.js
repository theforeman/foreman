import {
  updatePassword,
  updatePasswordConfirmation,
} from '../PasswordStrengthActions';

describe('PasswordStrength actions', () => {
  it('should update password', () =>
    expect(updatePassword('some-password')).toMatchSnapshot());

  it('should update password-confirmation', () =>
    expect(updatePasswordConfirmation('some-password')).toMatchSnapshot());
});
