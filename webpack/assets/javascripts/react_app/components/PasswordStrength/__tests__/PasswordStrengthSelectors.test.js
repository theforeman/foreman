import { doesPasswordsMatch } from '../PasswordStrengthSelectors';

describe('PasswordStrength selectors', () => {
  describe('doesPasswordsMatch', () => {
    const expectPasswordsMatch = ({ password, passwordConfirmation }) =>
      expect(doesPasswordsMatch({ password, passwordConfirmation }));

    it('should not match different passwords', () =>
      expectPasswordsMatch({
        password: 'password',
        passwordConfirmation: 'different-password',
      }).toBe(false));

    it('should match empty state', () => expectPasswordsMatch({}).toBe(true));

    it('should match empty password-confirmation', () =>
      expectPasswordsMatch({ password: 'some-password' }).toBe(true));

    it('should match same password', () =>
      expectPasswordsMatch({
        password: 'password',
        passwordConfirmation: 'password',
      }).toBe(true));
  });
});
